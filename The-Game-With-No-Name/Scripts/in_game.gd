extends Control
class_name InGame

@export var game: Game

@onready var sound_manager: Node = $HBoxContainer/ViewportContainerP1/SubViewport/SoundManager

@onready var viewport_container: Array[SubViewportContainer] = [
	$HBoxContainer/ViewportContainerP1,
	$HBoxContainer/ViewportContainerP2
]

@onready var viewport: Array[SubViewport] = [
	$HBoxContainer/ViewportContainerP1/SubViewport, 
	$HBoxContainer/ViewportContainerP2/SubViewport
]

@onready var camera: Array[Camera2D] = [
	$HBoxContainer/ViewportContainerP1/SubViewport/Camera2D,
	$HBoxContainer/ViewportContainerP2/SubViewport/Camera2D
]

@onready var hp_bar: Array[HealthBar] = [$Player1/HPBar, $Player2/HPBar]
@onready var mana_bar: Array[HealthBar] = [$Player1/Mana, $Player2/Mana]
@onready var player_bar: Array[Control] = [$Player1, $Player2]
@onready var panel: Panel = $Panel

@onready var player: Array[Player] = [$HBoxContainer/ViewportContainerP1/SubViewport/Player1, $HBoxContainer/ViewportContainerP1/SubViewport/Player2]
var level: Node2D = null


func _ready() -> void:
	G.health_value_changed.connect(on_health_value_changed)
	G.mana_value_changed.connect(on_mana_value_changed)
	
	for i: int in Save.player.hp.size():
		on_health_value_changed(i, Save.player.hp[i])
		on_mana_value_changed(i, Save.player.mana[i])
		viewport[i].render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE


func add_level(currentLevel: Node2D) -> void:
	level = currentLevel
	viewport[0].add_child(level)
	viewport[1].world_2d = viewport[0].world_2d


func set_viewport_size() -> void:
	panel.visible = game.player_alive[0] and game.player_alive[1]
	
	if panel.visible:
		for i: int in game.player_alive.size():
			_set_player_viewport(i, 512, true)
	else:
		var active: int = 0 if game.player_alive[0] else 1
		_set_player_viewport(active, 1024, true)
		_set_player_viewport(1 - active, 0, false)


func _set_player_viewport(index: int, width: int, view_visible: bool) -> void:
	viewport[index].size.x = width
	show_player_bar(index, view_visible)
	viewport_container[index].visible = view_visible

func show_player_bar(index: int, show_bar: bool) -> void:
	player_bar[index].visible = show_bar


func connect_camera_to_player() -> void:
	for i: int in player.size():
		print("Player" , player)
		player[i].connect_camera(camera[i])


func on_health_value_changed(player_number: int, health_value: float) -> void:
	print("health value changed Player: ", player_number, " ", health_value)
	var bar: HealthBar = hp_bar[player_number]
	if health_value == 100:
		bar.set_value_int(health_value)
	else:
		bar.set_percent_value_int(health_value)


func on_mana_value_changed(player_number: int, mana_value: float) -> void:
	var bar: HealthBar = mana_bar[player_number]
	if mana_value >= 99:
		bar.set_value_int(mana_value)
	else:
		bar.set_percent_value_int(mana_value)
