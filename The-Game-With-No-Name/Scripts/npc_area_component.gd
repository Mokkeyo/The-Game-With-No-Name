extends Area2D
class_name NpcArea

var parent: Node2D
var player: Player = null
@export var ping: Ping

func _ready() -> void:
	parent = get_parent()
	parent.set_process_unhandled_input(false)

func check_for_player() -> bool:
	if player:
		if not player.freeze and C.pressed(C.interact, 0) and (G.playerInAirship[0] or player.is_on_floor()):
			G.npc = get_parent()
			return true
	return false


func check_for_player_inside_area(body: Node2D, add_player: bool) -> void:
	if not body is Player:
		return
	
	var playerNode: Player = body
	
	if playerNode.is_in_group("Player_0") and not playerNode.freeze:
		parent.set_process_unhandled_input(add_player)
		player = body if (add_player) else null
		if ping:
			ping.visible = add_player


func _on_body_entered(body: Node2D) -> void: check_for_player_inside_area(body, true)
func _on_body_exited(body: Node2D) -> void: check_for_player_inside_area(body, false)
