extends Area2D
class_name AirshipDetector

var focus_player: Airship = null
var next_player: Airship = null

func changeTarget() -> void:
	if focus_player and next_player:
		var temp_player: Airship = focus_player
		focus_player = next_player
		next_player = temp_player


func _on_body_exited(body: Airship) -> void:
	if body == focus_player:
		focus_player = next_player
	next_player = null


func _on_body_entered(body: Airship) -> void:
	if focus_player:
		next_player = body
		return
	focus_player = body
