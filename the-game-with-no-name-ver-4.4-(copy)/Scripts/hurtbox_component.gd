extends Area2D
class_name HurtBox

@export var health: healthComponent

func damage(dmg: int, knockback: float) -> void:
	health.damage(dmg, knockback)
