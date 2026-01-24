extends PlayerState

@export var launch_speed_multiplier: float = 2.0

func enter() -> void:
	player.play_animation("jump")


func physics_update(_delta: float) -> void:
	# feste Bewegung in Launch-Richtung
	player.velocity = player.bubble_direction * player.SPEED * launch_speed_multiplier

	# Kollision → Launch endet
	if player.get_slide_collision_count() > 0:
		player.change_state("air")
