extends PlayerState

@export var stop_threshold: float = 10
@export var dampening: float = 900

func enter() -> void:
	player.play_animation("jump")

func physics_update(delta: float) -> void:
	# Knockback-Bewegung
	player.velocity = player.knockback
	player.knockback = player.knockback.move_toward(
		Vector2.ZERO,
		dampening * delta
	)

	# Wenn fast gestoppt → zurück in Air
	if player.knockback.length() <= stop_threshold:
		player.knockback = Vector2.ZERO
		player.change_state("air")
