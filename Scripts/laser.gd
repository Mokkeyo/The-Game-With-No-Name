extends RayCast2D
class_name Laser

var time: float = 1.0

func _process(delta: float) -> void:
	time -= delta
	if time < 0:
		queue_free()

	var move: Vector2 = Vector2(1,0).rotated(self.rotation)
	global_position += move * 1000 * delta
