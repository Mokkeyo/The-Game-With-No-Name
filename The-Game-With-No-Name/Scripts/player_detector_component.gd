extends Area2D
class_name PlayerDetector

var focus_player: Node2D = null
var next_player: Node2D = null

func changeTarget() -> void:
	if focus_player and next_player:
		var temp_player: Player = focus_player
		focus_player = next_player
		next_player = temp_player


func _on_body_exited(body: Node2D) -> void:
	if body == focus_player:
		focus_player = next_player
	next_player = null


func _on_body_entered(body: Node2D) -> void:
	if focus_player:
		next_player = body
		return
	
	focus_player = body
