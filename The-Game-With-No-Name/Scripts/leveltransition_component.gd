extends Node2D
class_name LevelTransition

@export var marker: Marker2D
@export var area: Area2D
var level_number: int
var door_name: String

func check_for_transition() -> bool:
	for body: Player in area.get_overlapping_bodies():
		for i: int in range(G.playerAlive.size()):
			if body.is_in_group("Player_%d" % i) and C.pressed(C.interact, i) and body.is_on_floor():
				body.animatedSprite.play("door")
				body.position = marker.global_position
				transition()
				return true
	return false


func transition() -> void:
	G.next_level_door = door_name
	G.SaveStat.levelNumber = level_number
	G.SaveStat.checkpointActive = false
	G.tempDoor.clear()
	G.SaveStat.door.clear()
	G.playerInAirship.fill(false)
	G.save_data()
	G.emit_signal("enter_door")
