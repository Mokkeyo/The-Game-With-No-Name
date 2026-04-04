extends Node
class_name PlayerManager

@export var game: Game = null
#@export var in_game: InGame = null

var player_size: int
var player_spawner: PlayerSpawner

signal game_over_requested(player: int)
signal respawn_timer_requested
signal change_viewport_requested


func _ready() -> void:
	G.player_died.connect(on_player_count_changed)
	player_size = game.player_alive.size()


func get_player_spawner(level: Node2D) -> void:
	var player_spawner: PlayerSpawner = level.get_node_or_null("Player_Spawner")
	if not player_spawner:
		push_warning("Kein Player_Spawner Gefunden")
		return
	
	player_spawner.spawn_player(player_alive)


func on_player_count_changed(player: int) -> void:
	var player_alive: Array[bool] = game.player_alive
	if player > -1:
		game.player_alive[player] = not player_alive[player]
		if not player_alive[player]:
			G.save_stat_inf.deaths[G.active_slot] += 1
			G.save_options()
		
	var both_death: bool = not player_alive[0] and not player_alive[1]
	
	game.player_alive = player_alive
	
	if both_death:
		game_over_requested.emit(player)
		return
	if player > -1:
		respawn_timer_requested.emit()
	
	change_viewport_requested.emit()



func set_player_positions() -> void:
	for i: int in player_size:
		if game.player_alive[i] and in_game.player[i]:
			in_game.player[i].global_position = G.save_stat.checkpointPosition 
