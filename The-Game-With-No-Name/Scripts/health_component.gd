extends Node
class_name HealthComponent

signal value_changed
signal died

@export_group("Stats")
@export var health: float = 20
@export var invisibiltyFrames: float = 0.5
@export var knockbackDirection: Vector2
@export var knockbackDuration: float = 0.1

@export_group("Components")
@export var lavaDetector: LavaWaterDetector
@export var health_bar: HealthBar

var max_health: float

func _ready() -> void:
	max_health = health


func damage(dmg: int) -> void:
	if health <= 0:
		return
	
	health -= dmg
	value_changed.emit()
	
	update_hpbar(int(health))
	
	if health <=  0:
		died.emit()
		return


func refill_health(value: int) -> void:
	health = value
	
	if health > max_health:
		health = max_health

	update_hpbar(int(health))


func update_hpbar(value: int) -> void:
	if health_bar:
		health_bar.set_percent_value_int(value)


func die() -> void:
	health = 0
	
	value_changed.emit()
	died.emit()
