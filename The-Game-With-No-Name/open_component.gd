extends Node2D
class_name OpenComponent

@export var door: DoorWithObj = null

func open_door() -> void:
	if not door:
		push_warning("No Door Selected")
		return
	
	door.open()
