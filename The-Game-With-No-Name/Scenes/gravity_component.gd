extends Node
class_name GravityComponent

@export var gravity: float = 800.0
@export var terminal_velocity: float = 1000.0

func apply_gravity(velocity: Vector2, delta: float) -> Vector2:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, terminal_velocity)
	return velocity
