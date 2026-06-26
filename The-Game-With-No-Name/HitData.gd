extends Resource
class_name HitData

enum KnockbackType {
	NONE, # Kein Knockback
	NORMAL, # Knockback immer gleich
	EXPLOSION, #Je weiter das Ziel weg, desto kleiner der Knockback
	UP, # Knockback Explezit nach Oben
	DOWN, # Knockback Explezit nach Unten
}

var damage: int
var damage_type: G.DamageType

var source: Node2D

var knockback_force: float
var knockback_type: KnockbackType = KnockbackType.NORMAL

var updward_force: float = 0.2
var radius: float = 0.0
