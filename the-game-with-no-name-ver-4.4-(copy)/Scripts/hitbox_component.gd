extends Area2D
class_name HitBox

signal damage_dealth
@export var health: healthComponent
@export var dmg_count: int = 20
@export var knockback: float = 0

func _on_area_entered(area: HurtBox) -> void:
	if not health or health and health.health > 0:
		emit_signal("damage_dealth")
		if area.global_position.x > global_position.x:
			area.damage(dmg_count, knockback)
		else:
			area.damage(dmg_count, -knockback)
