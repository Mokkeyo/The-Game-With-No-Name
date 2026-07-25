extends Node2D
class_name Projectile

signal finished(projetile: Projectile)

@export var hitbox: HitBox

func _ready() -> void:
	assert(hitbox)

func configure(_definition: ProjectileDefinition) -> void:
	pass

func shoot(_pos: Vector2, _rot: float, _owner: Node2D) -> void:
	pass

func deactivate() -> void:
	visible = false
	hitbox.set_deferred("monitoring", false)
	set_physics_process(false)
	global_position = Vector2(-1000, -1000)

func finish() -> void:
	finished.emit(self)
