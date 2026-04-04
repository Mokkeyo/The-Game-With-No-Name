extends Node
class_name UIManager

@onready var hp_bar: Array[progressBar] = [$Player1/HPBar, $Player2/HPBar]
@onready var mana_bar: Array[progressBar] = [$Player1/Mana, $Player2/Mana]
@onready var player_bar: Array[Control] = [$Player1, $Player2]
@onready var boss_node: Control = $Boss
@onready var boss_hp_bar: progressBar = $Boss/BossHP
@onready var boss_label: Label = $Boss/Label

func _ready() -> void:
	G.health_value_changed.connect(_on_health_value_changed)
	G.mana_value_changed.connect(_on_mana_value_changed)
	G.boss_begin.connect(_show_boss_hp)
	G.boss_finished.connect(hide_boss_hp)
	G.boss_value_changed.connect(change_boss_hp)
	G.boss_label_changed.connect(change_boss_label)
	
	for i: int in G.save_stat.playerHp.size():
		_on_health_value_changed(i, G.save_stat.playerHp[i])
		_on_mana_value_changed(i, G.save_stat.playerMana[i])


func show_player_bar(player: int, value: bool = true) -> void:
	player_bar[player].visible = value


func _on_health_value_changed(player_number: int, health_value: int) -> void:
	var bar: progressBar = hp_bar[player_number]
	if health_value == 100:
		bar.set_value_int(health_value)
	else:
		bar.set_percent_value_int(health_value)


func _on_mana_value_changed(player_number: int, mana_value: int) -> void:
	var bar: progressBar = mana_bar[player_number]
	if mana_value >= 99:
		bar.set_value_int(mana_value)
	else:
		bar.set_percent_value_int(mana_value)


func _show_boss_hp(label: String, hp: int) -> void:
	change_boss_hp(hp)
	change_boss_label(label)
	boss_node.visible = true


func hide_boss_hp() -> void:  boss_node.visible = false
func change_boss_hp(boss_hp: int) -> void: boss_hp_bar.set_percent_value_int(boss_hp)
func change_boss_label(label: String) -> void: boss_label.text = label
