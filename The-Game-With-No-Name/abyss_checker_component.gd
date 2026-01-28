extends Node
class_name AbyssCheckerComponent

@export var raycast: RayCast2D

func is_over_abyss() -> bool:
	if not raycast:
		push_warning("no raycast to detect abyss connected")
		return false
	
	raycast.force_raycast_update()
	return raycast.get_collider() == null
