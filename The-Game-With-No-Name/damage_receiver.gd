extends Node
class_name DamageReciever

signal damage_dealt

@export var health: HealthComponent = null
@export var invincibility: InvisibleFramesComp = null
@export var damage_sound: SoundEffect = null

@export var knockback: KnockbackComponent

@export var invincibility_time: float = 0.5

@export var ignore_damage: Array[HitData.DamageType]

func receive_damage(hit: HitData) -> void:
	if ignore_damage.has(hit.damage_type):
		return
	
	match hit.damage_type:
		HitData.DamageType.NORMAL:
			if invincibility and invincibility.Iframes_active():
				return
			
			if invincibility:
				invincibility.play_invible_frames(invincibility_time)
		
		HitData.DamageType.LAVA, HitData.DamageType.ENVIRONMENT:
			pass
		HitData.DamageType.DOT:
			pass
	
	if damage_sound:
		var parent: Node2D = get_parent() as Node2D
		AudioManager.play_sfx(damage_sound, parent.global_position)
	damage_dealt.emit()
	
	if health:
		health.damage(hit.damage)
		
	if knockback:
		knockback.apply(hit)
