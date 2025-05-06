extends StaticBody2D
class_name Dummy
signal defeated

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var animationPlayer: AnimationPlayer = $DamagePlayer
@onready var HealthComponent: healthComponent = $healthComponent
@onready var hurtBoxCollision: CollisionShape2D = $Hurtbox/CollisionShape2D

var die: bool = false

func _ready() -> void:
	HealthComponent.connect("value_changed", Callable(self, "damage"))
	collision.disabled = bool(visible != true)
	hurtBoxCollision.disabled = bool(visible != true)

func damage() -> void:
	animationPlayer.play("Damage")
	if !die:
		if HealthComponent.health <= 0:
			emit_signal("defeated")
			die = true
