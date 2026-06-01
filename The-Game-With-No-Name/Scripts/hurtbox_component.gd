extends Area2D
class_name HurtBox

@export var damage_receiver: DamageReciever

signal damaged(amount: int, knockback: float, d_type: G.DamageType)

func receive_hit(dmg: int, knockback: float, d_type: G.DamageType) -> void:
	damaged.emit(dmg, knockback, d_type)
	
	if damage_receiver:
		damage_receiver.receive_damage(dmg, knockback, d_type)
	else:
		push_warning("no damage reciever set for: " + get_parent().name)
