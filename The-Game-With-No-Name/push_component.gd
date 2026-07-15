extends Node
class_name PushComponent

@export var push_force: int = 60

var body: CharacterBody2D = null

func setup(body_node: CharacterBody2D) -> void:
#	assert(body)
	body = body_node

func push() -> void:
	for i: int in body.get_slide_collision_count():
		var collision: KinematicCollision2D = body.get_slide_collision(i)
		var block: MovableBlock = collision.get_collider() as MovableBlock
		if block == null:
			continue
		
		block.apply_central_impulse(-collision.get_normal() * push_force)
