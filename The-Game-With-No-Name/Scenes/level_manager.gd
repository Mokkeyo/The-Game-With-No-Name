extends Node
class_name LevelManager

@export var game: Game = null
@export var in_game: InGame = null
@export var player_manager: PlayerManager = null
@export var fader: Fader

var level: Node2D

func setup_level() -> void:
	var currentLevel: PackedScene = load("res://Level/level_%d.tscn" % G.save_stat.levelNumber)
	level = currentLevel.instantiate()
	game.in_game.add_level(level)
	
	player_manager.get_player_spawner(level)
	
	in_game.connet_camera_to_player()
	fader.fade_in()


func change_level() -> void:
	G.save_stat.door.clear()
	var start_time: float = Time.get_ticks_msec()
	await fader.fade_out().animation_finished
	
	get_tree().paused = false
	
	in_game.viewport[0].remove_child(level)
	level.queue_free()
	setup_level()
	
	print("Reload duration: ", Time.get_ticks_msec() - start_time, "ms")
