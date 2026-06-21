extends BossAttack
class_name AxtAttack

func can_use() -> bool:
	var player: Player = boss.player_detector.focus_player
	
	if player == null:
		return false
	
	var distance: float = player.global_position.distance_to(boss.global_position)
	
	return distance <= 120


func start() -> void:
	var side: String = "Right" if boss.sprite.flip_h else "Left"
	
	boss.animation_player.play("Axt_Close_" + side)
	
	boss.state = Hades.State.ATTACKING
	
	await boss.animation_player.animation_finished
	
	finish()
