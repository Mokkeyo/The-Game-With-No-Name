extends Area2D
class_name HurtBox

@export var damage_receiver: DamageReciever

signal damaged(amount: int, knockback: float, d_type: HitData.DamageType)

func receive_hit(hit: HitData) -> void:
	damaged.emit(hit)
	
	if damage_receiver:
		damage_receiver.receive_damage(hit)
	else:
		push_warning("no damage reciever set for: " + get_parent().name)
