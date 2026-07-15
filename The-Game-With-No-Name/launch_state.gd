extends PlayerState
class_name LaunchState

@export var launch_speed_multiplier: float = 2.0

func enter() -> void:
	animation.play(animation.Anim.JUMP)


func physics_update(_delta: float) -> void:
	player.velocity = player.launch_direction * movement.speed * launch_speed_multiplier
	
	player.move_and_slide()
	
	if player.get_slide_collision_count() > 0:
		player.state_machine.change_state(ID.AIR)
