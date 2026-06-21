extends BossAttack
class_name DashAttack

var speed: float = 200
var awaiting: float = 0.7

func can_use() -> bool:
	var player: Player = boss.player_detector.focus_player
	
	if player == null:
		return false
	
	var distance: float = player.global_position.distance_to(boss.global_position)
	
	return distance > 120


func start() -> void:
	var side: String = "Right" if boss.sprite.flip_h else "Left"
	
	boss.animation_player.play("Dash_" + side)
	
	boss.state = Hades.State.ATTACKING


func update(delta: float) -> void:
	
	awaiting -= delta
	
	if awaiting > 0:
		return
	
	boss.move_and_slide()
	
	boss.velocity.x = speed if boss.sprite.flip_h else - speed
	
	if boss.is_on_wall():
		boss.velocity = Vector2.ZERO
		boss.fall.emit()
#		boss.animation_player.play("WallCrash")
		
		boss.state = Hades.State.STUNNED
		stun()


func finish() -> void:
	super.finish()
	awaiting = 0.7


func stun() -> void:
	await boss.get_tree().create_timer(2).timeout
	finish()
