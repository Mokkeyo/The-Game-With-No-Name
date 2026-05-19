extends Node
class_name LevelManager

var current_level: Node2D
var current_level_number: int

var player_spawner: PlayerSpawner
var respawnable_obj: Array[EnemyResetComponent]


func is_same_level(level_number: int) -> bool:
	return level_number == current_level_number


func transition_new_level(level_number: int) -> Node2D:
	await unload_current_level()
	return load_level(level_number)


func unload_current_level() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null
	await get_tree().process_frame


func load_level(level_number: int) -> Node2D:
	var packed: PackedScene = load("res://Level/level_%d.tscn" % level_number)
	
	current_level_number = level_number
	current_level = packed.instantiate()
	
	player_spawner = current_level.get_node_or_null("Player_Spawner")
	get_respawnable_obj()
	return current_level


#func change_level(level_number: int) -> void:
#	if not is_same_level(level_number):
#		await transition_new_level(level_number)


func get_respawnable_obj() -> void:
	respawnable_obj.clear()
	_collect_respawnables(current_level)


func _collect_respawnables(node: Node) -> void:
	if node.is_in_group("respawnable"):
		respawnable_obj.append(node)
	
	for child: Node in node.get_children():
		_collect_respawnables(child)


func reload_level() -> void:
	reset_respawnable_obj()


func reset_respawnable_obj() -> void:
	for obj: EnemyResetComponent in respawnable_obj:
		if not obj.is_in_group("Player"):
			obj.reset_stats()


func get_spawn_position() -> Vector2:
	if Save.player.checkpointActive:
		return Save.player.checkpointPosition
	elif player_spawner != null:
		return player_spawner.global_position
	
	push_warning("neither player_spawner nor checkpoint found")
	return Vector2.ZERO


func get_door_position(door_name: String) -> Vector2:
	if door_name == "":
		return player_spawner.global_position
	
	var door: Node2D = current_level.find_child(door_name)
	
	if not door:
		push_error("Door not found: " + door_name)
		return player_spawner.global_position
	
	return door.global_position
