extends Control
class_name InGame

@onready var viewport_containers: Array[SubViewportContainer] = [
	$HBoxContainer/ViewportContainerP1,
	$HBoxContainer/ViewportContainerP2
]

@onready var viewports: Array[SubViewport] = [
	$HBoxContainer/ViewportContainerP1/SubViewport, 
	$HBoxContainer/ViewportContainerP2/SubViewport
]

@onready var cameras: Array[Camera2D] = [
	$HBoxContainer/ViewportContainerP1/SubViewport/Camera2D,
	$HBoxContainer/ViewportContainerP2/SubViewport/Camera2D
]

@onready var hp_bars: Array[HealthBar] = [%HpP1, %HpP2]
@onready var mana_bars: Array[HealthBar] = [%ManaP1, %ManaP2]
@onready var player_bars: Array[Control] = [$CanvasLayer/Player1, $CanvasLayer/Player2]
@onready var panel: Panel = $CanvasLayer/Panel

var old_level: Node2D = null

func get_players() -> Array[Player]:
	return [%Player1, %Player2]

func get_pets() -> Array[Pet]:
	return [%GhostPet1, %GhostPet2]


func _ready() -> void:
	G.level_viewport = $HBoxContainer/ViewportContainerP1/SubViewport
	G.health_value_changed.connect(on_health_value_changed)
	G.mana_value_changed.connect(on_mana_value_changed)
	
	for i: int in Save.player.hp.size():
		on_health_value_changed(i, Save.player.hp[i])
		on_mana_value_changed(i, Save.player.mana[i])
		viewports[i].render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE


func add_level(level: Node2D) -> void:
	if old_level != null:
		viewports[0].remove_child(old_level)
	
	old_level = level
	viewports[0].add_child(level)
	viewports[1].world_2d = viewports[0].world_2d


func set_viewport_size(player_alive: Array[bool]) -> void:
	panel.visible = player_alive[0] and player_alive[1]
	
	if panel.visible:
		for i: int in player_alive.size():
			show_player_bar(i, true)
			_set_player_viewport(i, 512, true)
	else:
		var active: int = 0 if player_alive[0] else 1
		_set_player_viewport(active, 1024, true)
		show_player_bar(active, true)
		_set_player_viewport(1 - active, 0, false)
		show_player_bar(1- active, false)


func _set_player_viewport(index: int, width: int, view_visible: bool) -> void:
	viewports[index].size.x = width
	show_player_bar(index, view_visible)
	viewport_containers[index].visible = view_visible


func show_player_bar(index: int, show_bar: bool) -> void:
	player_bars[index].visible = show_bar


func disable_cameras() -> void:
	for camera: Camera2D in cameras:
		camera.enabled = false
	
	var p: Array[bool] = [true, false]
	set_viewport_size(p)


func enable_cameras() -> void:
	for camera: Camera2D in cameras:
		camera.enabled = true


func connect_camera_to_players(players: Array[Player]) -> void:
	for i: int in players.size():
		players[i].connect_camera(cameras[i].get_path())


func on_health_value_changed(player_number: int, health_value: float) -> void:
	var bar: HealthBar = hp_bars[player_number]
	if health_value == 100:
		bar.set_value_int(health_value)
	else:
		bar.set_percent_value_int(health_value)
	Save.player.hp[player_number] = health_value

func on_mana_value_changed(player_number: int, mana_value: float) -> void:
	var bar: HealthBar = mana_bars[player_number]
	if mana_value >= 99:
		bar.set_value_int(mana_value)
	else:
		bar.set_percent_value_int(mana_value)
