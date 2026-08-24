extends Node
class_name NavigationComponent

@export var agent: NavigationAgent2D
@export var parent: CharacterBody2D
@export var ray: RayCast2D
@export var speed: float

func move_to(target_position: Vector2) -> void:
	agent.target_position = target_position
	
	if agent.is_navigation_finished():
		parent.velocity = Vector2.ZERO
		return
	
	var next_pos: Vector2 = agent.get_next_path_position()
	var dir: Vector2 = (next_pos - parent.global_position).normalized()
	
	if ray:
		dir = avoid_obstacle(dir)
	
	parent.velocity = dir * speed


func avoid_obstacle(dir: Vector2) -> Vector2:
	ray.target_position = dir * 50
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var normal: Vector2 = ray.get_collision_normal()
		return dir.slide(normal)
	
	return dir
