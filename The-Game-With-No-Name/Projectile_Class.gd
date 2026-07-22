extends Node2D
class_name Projectile

signal finished(projetile: Projectile)

func shoot(_position: Vector2, _rotation: float, _owner: Node2D) -> void:
	pass

func deactivate() -> void:
	visible = false
	set_physics_process(false)

func finish() -> void:
	finished.emit(self)
