extends Resource
class_name HitData

enum KnockbackType {
	NONE, # Kein Knockback
	NORMAL, # Knockback immer gleich
	EXPLOSION, #Je weiter das Ziel weg, desto kleiner der Knockback
	UP, # Knockback Explezit nach Oben
	DOWN, # Knockback Explezit nach Unten
	VERTIKAL, # Knockback nu nach rechts und links
}

enum  DamageType {
	NORMAL,
	LAVA,
	DOT,
	ENVIRONMENT,
	ON_JUMP,
	PROJECTILE,
	}

var damage: int
var damage_type: DamageType

var source: Node2D

var knockback_force: float
var knockback_type: KnockbackType = KnockbackType.NORMAL

var updward_force: float = 0.2
var radius: float = 0.0
