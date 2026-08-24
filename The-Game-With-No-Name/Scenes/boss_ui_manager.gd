extends Control
class_name BossUIManager

@onready var hp_bar: HealthBar = $BossHP
@onready var label: Label = $Label

func setup() -> void:
	visible = false


func show_boss(boss_name: String, boss_hp: float) -> void:
	visible = true
	
	set_label(boss_name)
	set_hp(boss_hp)


func hide_boss() -> void:
	visible = false


func set_hp(value: float) -> void:
	hp_bar.set_percent_value_int(value)


func set_label(value: String) -> void:
	label.text = value
