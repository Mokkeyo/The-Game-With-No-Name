extends Node2D
class_name PlayerSpawner

@export var airship_spawner: AirshipSpawner
@onready var player: Array[Player] =  [$Player_1, $Player_2]

func spawn_player(player_alive: Array[bool]) -> void:
	var player_position: Array[Marker2D] = [$Player_1_Position, $Player_2_Position]
	
	if not G.save_stat.checkpointActive and not G.save_stat.checkpointPosition == global_position:
		G.save_stat.checkpointPosition = player[0].global_position
		G.save_data()
	
	for i: int in player.size():
		player[i].current_player = i
		if player_alive[i- 1]:
			player[i].reset_comp.set_stats()
		call_deferred("add_player", player[i], player_position[i].global_position)
	visible = false
	
	if airship_spawner:
		airship_spawner.spawn_airship(player_alive)


func add_player(player_i: Player, p_position: Vector2) -> void:
	remove_child(player_i)
	get_parent().add_child(player_i)
	player_i.set_multiplayer_authority(player_i.current_player + 1)
	player_i.global_position = G.save_stat.checkpointPosition if G.checkpoint_activated else p_position
