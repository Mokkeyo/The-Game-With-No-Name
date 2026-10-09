extends Area2D
class_name InteractionArea

signal interacted(player: Player)

var parent: Node2D
var players: Array[Player] = []

@export var ping: Ping
@export var unhandled_input: bool = true

func _ready() -> void:
	parent = get_parent()
	set_process_unhandled_input(false)


func _unhandled_input(_event: InputEvent) -> void:
	check_for_player()



func check_for_player() -> void:
	for player: Player in players:
		if player.is_in_state(PlayerStates.ID.FREEZE):
			continue
		
		if not player.is_on_floor():
			continue
		
		if player.is_in_group("Player_0"):
			if Input.is_action_just_pressed("player1_interact"):
				interacted.emit(player)

		if player.is_in_group("Player_1"):
			if Input.is_action_just_pressed("player2_interact"):
				interacted.emit(player)


func check_for_player_inside_area(body: Node2D, add_player: bool) -> void:
	if not body is Player:
		return
	
	var player: Player = body

	if not add_player:
		players.erase(player)
	else:
		if not players.has(player):
			players.append(player)

	if unhandled_input:
		set_process_unhandled_input(not players.is_empty())
		if ping:
			var player_numb: int = 0 if body.is_in_group("Player_0") else 1
			ping.display_key(player_numb, not players.is_empty())




func _on_body_entered(body: Node2D) -> void: check_for_player_inside_area(body, true)
func _on_body_exited(body: Node2D) -> void: check_for_player_inside_area(body, false)
