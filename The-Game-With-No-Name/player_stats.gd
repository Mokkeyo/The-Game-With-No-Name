extends Node
class_name PlayerStats

signal health_changed(value: int)
signal mana_changed(value: int)
signal died

@export var max_health: int = 100
@export var max_mana: int = 100

var health: int
var mana: int

func setup(start_health: int, start_mana: int) -> void:
	health = clamp(start_health, 0, max_health)
	mana = clamp(start_mana, 0, max_mana)
	health_changed.emit(health)
	mana_changed.emit(mana)
