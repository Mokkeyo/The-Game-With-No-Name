extends Node2D
class_name LevelTransition

@export var marker: Marker2D
@export var level_number: int
@export var door_name: String = ""


func transition(body: Player = null) -> void:
	if body:
		body.animation.play(body.animation.Anim.DOOR)
		body.position = marker.global_position
	
	G.enter_door.emit(level_number, door_name)
