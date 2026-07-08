extends BossAttack
class_name SlamAttack

var target_position: Vector2

func can_use() -> bool:
	var player: Player = boss.player_detector.focus_player
	
	if player == null:
		return false
	
	var distance: float = player.global_position.distance_to(boss.global_position)
	
	return distance > 120


func start() -> void:
	var side: String = "Right" if boss.sprite.flip_h else "Left"
	var player: Player = boss.player_detector.focus_player
	
	target_position = player.global_position
	
	boss.animation_player.play("Slam_" + side)
	
	jump()


func jump() -> void:
	boss.velocity.y = -600


func update(delta: float) -> void:
	
	boss.global_position.x = lerp(boss.global_position.x, target_position.x, 4 * delta)
	
	var was_in_air: bool = boss.is_on_floor() == false
	
	boss.move_and_slide()
	
	if boss.is_on_floor() and was_in_air:
		
		create_waves()
		
		await boss.animation_player.animation_finished
		
		if not boss.current_attack == self:
			return
		
		finish()


func create_waves() -> void:
	for wave: WaveComponent in boss.wave_component:
		wave.wave_point = boss.marker[1] if boss.sprite.flip_h else boss.marker[0]
		wave.shoot_wave()
