extends Area2D
class_name HurtBox

@export var damage_receiver: DamageReciever

signal damaged(amount: int, knockback: float, damage_type: int)

func receive_hit(dmg: int, knockback: float, damage_type: int) -> void:
	damaged.emit(dmg, knockback, damage_type)
	
	if damage_receiver:
		damage_receiver.receive_damage(dmg, knockback, damage_type)
