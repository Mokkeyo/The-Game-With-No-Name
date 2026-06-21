extends Node
class_name PlattformSnapComponent

@export var body: CharacterBody2D

func apply_platform_movement() -> void:
	if not body.is_on_floor():
		return
	
	for i: int in body.get_slide_collision_count():
		var col: KinematicCollision2D = body.get_slide_collision(i)
		
		if col.get_normal().dot(Vector2.UP) > 0.7:
			var collider: Node2D = col.get_collider()
			
			if collider.has_node("MoverComponent"):
				var mover: MoverComponent = collider.get_node("MoverComponent")
				if mover:
					var delta: Vector2 = collider.global_position - mover.last_position
					body.global_position += delta
