extends Sprite2D
class_name Key

signal key_collected

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("key_collected")
		call_deferred("disable_collision")
		visible = false

func disable_collision() -> void:
	var collision: CollisionShape2D = $Area2D/CollisionShape2D
	collision.disabled = true
