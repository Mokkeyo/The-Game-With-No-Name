extends Area2D
class_name HurtBox

@export var damage_receiver: DamageReciever

func receive_hit(hit: HitData) -> void:
	if damage_receiver:
		damage_receiver.receive_damage(hit)
	else:
		push_warning("no damage reciever set for: " + get_parent().name)
