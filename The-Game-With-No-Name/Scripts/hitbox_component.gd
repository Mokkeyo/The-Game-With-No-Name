extends Area2D
class_name HitBox

signal hit(target: HurtBox, damage: int, knockback: float)
signal damaged_enemy

@export var dmg: int = 20
@export var knockback: float = 0
@export var damage_type: G.DamageType = G.DamageType.NORMAL

func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
#		hit.emit(dmg, knockback)
		damaged_enemy.emit()
		var hurtbox: HurtBox = area as HurtBox
		hurtbox.receive_hit(dmg, knockback, damage_type)
