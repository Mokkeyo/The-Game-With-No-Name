extends Area2D
class_name PlayerDetector

var focus_player: Player = null
var next_player: Player = null

func changeTarget() -> void:
	if focus_player and next_player:
		var temp_player: Player = focus_player
		focus_player = next_player
		next_player = temp_player


func _on_body_exited(body: Player) -> void:
	if body == focus_player:
		focus_player = next_player
	next_player = null


func _on_body_entered(body: Player) -> void:
	if focus_player:
		next_player = body
		return
	
	focus_player = body
