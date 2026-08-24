extends Node
class_name AirshipEntryComponent

@export var area: Area2D = null
@export var collisions: Array[CollisionShape2D] = []

var player: Player

func setup(body: Player) -> void:
	assert(body)
	player = body

func handle_airship_entry() -> void:
	assert(area)
	
	for object: Node2D in area.get_overlapping_bodies():
		if object == null:
			break
		
		if object.is_in_group(str("airship_", player.current_player)):
			await get_tree().process_frame
			var airship: Airship = object
			enter_airship(airship)
			break


func enter_airship(object: Airship) -> void:
	for collision: CollisionShape2D in collisions:
		collision.disabled = true
	object.go_in(player)
	player.visible = false
