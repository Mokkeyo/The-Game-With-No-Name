extends Node2D

var time: float = 1.5

func _process(delta: float) -> void:
	time -= delta
	if time < 0:
		queue_free()

	var move: Vector2 = Vector2(0,1)
	global_position += move * 150 * delta
