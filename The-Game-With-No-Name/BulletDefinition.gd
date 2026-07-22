extends ProjectileDefinition
class_name BulletDefinition

enum BulletType {PLAYER_1, PLAYER_2, ENEMY}

@export var speed: int = 300
@export var lifetime: float = 2.0
@export var bullet_type: BulletType

func _init() -> void:
	scene = preload("res://Scenes/bullet.tscn")
