extends Node
class_name PlayerManager

signal all_player_died
signal player_respawned(value: int)
signal multiplayer_changed(value: bool)

var time: float = 1.0
var time_left: int = 3:
	set(value):
		time_left = value
		timer_label.text = str(value)



@export var player_label: Array[Label]
@onready var despawn_timer: Timer = $DespawnTimer
@onready var timer_label: Label

var multiplayer_enabled: bool = false:
	set(value):
		multiplayer_enabled = value
		multiplayer_changed.emit(value)

var despawn_input: int = -1
var just_despawned: bool = false

var player_alive: Array[bool] = [true, false]
var respawn_time: float = 5.0

var players: Array[Player] = []
var pets: Array[Pet] = []

func setup(t_players: Array[Player], t_pets: Array[Pet], t_label: Label) -> void:
	players = t_players
	t_label.visible = false
	timer_label = t_label
	pets = t_pets
	t_players[1].reset_comp.disable_stats()
	set_process(false)
	despawn_timer.timeout.connect(deactivate_player_2)

	player_alive[1] = false
	for i: int in t_players.size():
		t_players[i].health_component.health = Save.player.hp[i]


func _process(delta: float) -> void:
	time -= delta

	if time <= 0:
		time += 1
		time_left -= 1
	

	if time_left <= 0:
		_on_respawn_timer_timeout()
		timer_label.hide()
		set_process(false)


func get_alive_players() -> Array[Player]:
	var arr: Array[Player] = []
	
	for i: int in players.size():
		if player_alive[i]:
			arr.append(players[i])
	
	return arr


func clear_footsteps_tilemap() -> void:
	pass


func get_dead_players() -> Array[Player]:
	var arr: Array[Player] = []
	
	for i: int in players.size():
		if not player_alive[i]:
			arr.append(players[i])
	
	return arr


func _unhandled_input(_event: InputEvent) -> void:
	check_for_respawn_input() 


func on_player_died(player: int) -> void:
	players[player].reset_comp.disable_stats()

	player_alive[player] = false
	
	if all_players_dead():
		Save.save_options()
		all_player_died.emit(player)
		return
	
	if not multiplayer_enabled:
		return
	
	time = 1
	time_left = 3
	timer_label.show()
	set_process(true)


func all_players_dead() -> bool:
	return not player_alive[0] and not player_alive[1]


func check_for_respawn_input() -> void:
	for i: int in player_alive.size():

		var player_input: String = "player%d_spawn" % int(i + 1)

		if Input.is_action_just_pressed(player_input):

			despawn_input = i

			if multiplayer_enabled:
				despawn_timer.start()


		elif Input.is_action_just_released(player_input):
			if not despawn_timer.is_stopped():
				despawn_timer.stop()

			if despawn_input == i and just_despawned:
				despawn_input = -1
				just_despawned = false
				return
			
			if not player_alive[i]:
				player_respawned.emit(i)
				if not multiplayer_enabled:
					multiplayer_enabled = true


func respawn_player(player_index: int , position: Vector2) -> void:
	player_label[player_index].visible = false
	
	player_alive[player_index] = true
	
	var player: Player = players[player_index]

	set_player_position(player_index, position)
	
	player.reset_comp.enable_stats()

	G.health_value_changed.emit(player_index, player.health_component.health)


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


func deactivate_player_2() -> void:
	just_despawned = true

	if not player_alive[0]:
		players[0].health_component.health = players[1].health_component.health
		
		respawn_player(0, players[1].global_position)

	if player_alive[1]:
		on_player_died(1)

	player_alive[1] = false

	multiplayer_enabled = false


func get_alive_states() -> Array[bool]:
	return player_alive
