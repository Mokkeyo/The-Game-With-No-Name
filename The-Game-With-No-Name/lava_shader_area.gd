extends Area2D
class_name LavaArea

signal player_near_lava(lava_pos : Vector2)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_near_lava.emit(global_position)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_near_lava.emit(Vector2.INF)
