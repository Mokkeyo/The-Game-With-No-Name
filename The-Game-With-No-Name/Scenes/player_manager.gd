extends Node
class_name PlayerManager

signal state_changed(player_id: int, new_state: Game.PlayerState)

var players: Array[Player]
var state: Array = []

func init(player_nodes: Array[Player]) -> void:
	players = player_nodes
	state.resize(players.size())
	state.fill(Game.PlayerState.ALIVE)

func kill(player_id: int) -> void:
	state[player_id] = Game.PlayerState.DEAD

func respawn(player_id: int, position: Vector2) -> void:
	state[player_id] = Game.PlayerState.ALIVE
	players[player_id].resetComp.reset_stats()
	players[player_id].global_position = position
	state_changed.emit(player_id, Game.PlayerState.ALIVE)

func both_dead() -> bool:
	return state[0] == Game.PlayerState.DEAD and state[1] == Game.PlayerState.DEAD
