extends Node2D

func _ready() -> void:
	var player: Array[Player] =  [$Player1, $Player2]
	var player_position: Array[Marker2D] = [$Player_1_Position, $Player_2_Position]
	
	if not G.SaveStat.checkpointActive and not G.SaveStat.checkpointPosition == global_position:
		G.SaveStat.checkpointPosition = player[0].global_position
		G.save_data()
	
	for i: int in player.size():
		var other_p: int = 0 if i == 1 else 1
		player[i].player = player[other_p]
		if not G.playerAlive[i]:
			player[i].resetComp.set_stats()
		call_deferred("add_player", player[i], player_position[i].global_position)
	visible = false


func add_player(player: Player, p_position: Vector2) -> void:
	remove_child(player)
	get_parent().add_child(player)
	if not G.checkpoint_activated:
		player.global_position = p_position
	else:
		player.global_position = G.SaveStat.checkpointPosition
