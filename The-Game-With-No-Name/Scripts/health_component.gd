extends Node
class_name HealthComponent

signal value_changed
signal died
signal setKnockback(strength: int)

@export_group("Stats")
@export var health: float = 20
@export var invisibiltyFrames: float = 0.5
@export var knockbackDirection: Vector2
@export var knockbackDuration: float = 0.1

@export_group("Components")
@export var invisibilityComp: InvisibleFramesComp
@export var lavaDetector: LavaWaterDetector

var max_health: float

func _ready() -> void:
	max_health = health
	
	if lavaDetector:
		lavaDetector.lava_entered.connect(die)


func damage(dmg: int, knockback: float) -> void:
	if health <= 0:
		return
	
	health -= dmg
	value_changed.emit()
	
	if health <=  0:
		died.emit()
		return
	
	if not knockback == 0:
		setKnockback.emit(knockback)


func die() -> void:
	health = 0
	
	value_changed.emit()
	died.emit()
