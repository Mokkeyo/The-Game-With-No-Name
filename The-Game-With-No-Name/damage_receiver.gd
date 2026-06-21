extends Node
class_name DamageReciever

@export var health: HealthComponent = null
@export var invincibility: InvisibleFramesComp = null
@export var invincibility_time: float = 0.5

@export var ignore_damage: Array[G.DamageType]

func receive_damage(dmg: int, knockback: float, damage_type: G.DamageType) -> void:
	if ignore_damage.has(damage_type):
		return
	
	match damage_type:
		G.DamageType.NORMAL:
			if invincibility and invincibility.Iframes_active():
				return
			if invincibility:
				invincibility.play_invible_frames(invincibility_time)
		
		G.DamageType.LAVA, G.DamageType.ENVIRONMENT:
			pass
		G.DamageType.DOT:
			pass
	
	if health:
		health.damage(dmg, knockback)
