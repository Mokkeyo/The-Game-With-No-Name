extends PlayerState
class_name WaterElevatorState

@export var lift_speed: float = 220.0

func enter() -> void:
	animation.play(animation.Anim.JUMP)


func handle_input() -> void:
	var dir: Vector2 = input_direction()
	
	update_combat(dir)
	
	movement.move_horizontal_water(
		dir.x, 
		combat.is_attacking()
	)
	
	update_flip(dir)


func physics_update(_delta: float) -> void:
	player.velocity.y = -lift_speed
	
	player.move_and_slide()
	
	if not player.lava_water_detector.in_water:
		player.state_machine.change_state(ID.AIR)
	else:
		player.state_machine.change_state(ID.WATER_AIR)
