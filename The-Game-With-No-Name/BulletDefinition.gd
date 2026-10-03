extends ProjectileDefinition
class_name BulletDefinition

enum BulletType {ENEMY, PLAYER_1, PLAYER_2}

@export var bullet_type: BulletType

func _init() -> void:
	scene = load("res://Scenes/bullet.tscn")
