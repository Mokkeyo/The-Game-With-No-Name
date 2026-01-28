extends Node
class_name DamageReciever

@export var health: HealthComponent = null
@export var invincibility: InvisibleFramesComp = null
@export var invincibility_time: float = 0.5

func receive_damage(dmg: int, knockback: float, damage_type: int) -> void:
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
