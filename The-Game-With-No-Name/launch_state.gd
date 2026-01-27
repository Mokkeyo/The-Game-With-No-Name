extends PlayerState
class_name LaunchState

@export var launch_speed_multiplier: float = 2.0

func enter() -> void:
	player.animation.play(player.animation.Anim.JUMP)


func physics_update(_delta: float) -> void:
	player.velocity = player.bubble_direction * player.movement.SPEED * launch_speed_multiplier

	# Kollision → Launch endet
	if player.get_slide_collision_count() > 0:
		player.change_state("air")
