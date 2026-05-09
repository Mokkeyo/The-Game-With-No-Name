extends Node2D
class_name LevelTransition

@export var marker: Marker2D
@export var area: Area2D
@export var level_number: int
@export var door_name: String = ""


func check_for_transition() -> bool:
	for body: Player in area.get_overlapping_bodies():
		for i: int in range(2):
			if body.is_in_group("Player_%d" % i) and Input.is_action_just_pressed("player%d_interact" % int(i + 1)) and body.is_on_floor():
				body.animation.play(body.animation.Anim.DOOR)
				body.position = marker.global_position
				transition()
				return true
	return false


func transition() -> void:
	print("transtioning to level")
	G.enter_door.emit(level_number, door_name)
