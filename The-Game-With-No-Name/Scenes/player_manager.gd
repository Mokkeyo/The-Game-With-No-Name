extends Node
class_name PlayerManager

signal all_player_died
signal player_count_changed
signal player_respawned(i: int)

@onready var player_label: Array[Label] = [$Player1Label, $Player2Label]
@onready var respawn_timer: Timer = $respawnTimer

var player_alive: Array[bool] = [true, false]
var respawn_time: float = 5.0

var players: Array[Player] = []
var pets: Array[Pet] = []

func setup(t_players: Array[Player], t_pets: Array[Pet]) -> void:
	set_process_unhandled_input(true)
	players = t_players
	pets = t_pets
	t_players[1].reset_comp.disable_stats()
	
	player_alive[1] = false
	for i: int in t_players.size():
		t_players[i].health_component.health = Save.player.hp[i]

func get_alive_players() -> Array[Player]:
	var arr: Array[Player] = []
	
	for i: int in players.size():
		if player_alive[i]:
			arr.append(players[i])
	
	return arr


func clear_footsteps_tilemap() -> void:
	SoundComp.tilemaps.clear()


func get_dead_players() -> Array[Player]:
	var arr: Array[Player] = []
	
	for i: int in players.size():
		if not player_alive[i]:
			arr.append(players[i])
	
	return arr


func _unhandled_input(_event: InputEvent) -> void:
	check_for_respawn_input() 


func on_player_died(player: int) -> void:
	player_alive[player] = false
	
	if all_players_dead():
		Save.options.deaths[SaveStateButton.state - 1] += 1
		Save.save_options()
		all_player_died.emit(player)
		return
	
	set_process_unhandled_input(false)
	respawn_timer.stop()
	respawn_timer.start()
	player_count_changed.emit()


func all_players_dead() -> bool:
	return not player_alive[0] and not player_alive[1]


func check_for_respawn_input() -> void:
	for i: int in player_alive.size():
		if Input.is_action_just_pressed("player%d_spawn" % int(i + 1)) and not player_alive[i]:
			set_process_unhandled_input(false)
			player_respawned.emit(i)
			break


func respawn_player(player_index: int , position: Vector2) -> void:
	player_label[player_index].visible = false
	
	player_alive[player_index] = true
	
	player_count_changed.emit()
	
	var player: Player = players[player_index]
	
	set_player_position(player_index, position)
	
	player.reset_comp.enable_stats()


func set_player_position(player: int, position: Vector2) -> void:
	players[player].global_position = position
	pets[0].global_position = position
	pets[1].global_position = position
	players[player].velocity = Vector2.ZERO


func _on_respawn_timer_timeout() -> void:
	for i: int in player_alive.size():
		if not player_alive[i]:
			player_label[i].visible = true
	
	var animation_player: AnimationPlayer = $AnimationPlayer
	animation_player.play("PlayerCanRespawn")
	set_process_unhandled_input(true)


func get_alive_states() -> Array[bool]:
	return player_alive
