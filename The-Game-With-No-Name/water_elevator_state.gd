extends PlayerState
class_name WaterElevatorState

@export var lift_speed: int = 220

func enter() -> void:
	player.animation.play(player.animation.Anim.JUMP)


func handle_input() -> void:
	var dir: int = player.input.move_dir()
	
	player.movement.move_horizontal(
		dir, 
		not player.combat.can_attack()
		)
	
	if not dir == 0:
		player.animation.flip(dir < 0)


func physics_update(_delta: float) -> void:
	player.velocity.y = -lift_speed
	
	player.move_and_slide()
	
	if not player.lava_water_detector.inWaterElevator:
		player.change_state("air")
