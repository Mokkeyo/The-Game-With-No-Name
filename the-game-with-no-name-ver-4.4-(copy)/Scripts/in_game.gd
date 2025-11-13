extends Control
class_name InGame

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

@onready var hp_bar: Array[progressBar] = [$Player1/HPBar, $Player2/HPBar]
@onready var mana_bar: Array[progressBar] = [$Player1/Mana, $Player2/Mana]
@onready var player_bar: Array[Control] = [$Player1, $Player2]
@onready var panel: Panel = $Panel

var player: Array[Player] = [null, null]
var level: Node2D = null


func _ready() -> void:
	G.health_value_changed.connect(on_health_value_changed)
	G.mana_value_changed.connect(on_mana_value_changed)
	
	for i: int in G.SaveStat.playerHp.size():
		on_health_value_changed(i, G.SaveStat.playerHp[i])
		on_mana_value_changed(i, G.SaveStat.playerMana[i])
		viewport[i].render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE


func add_level(currentLevel: Node2D) -> void:
	level = currentLevel
	viewport[0].add_child(level)
	viewport[1].world_2d = viewport[0].world_2d


func set_viewport_size() -> void:
	panel.visible = G.playerAlive[0] and G.playerAlive[1]
	
	if panel.visible:
		for i: int in range(G.playerAlive.size()):
			_set_player_viewport(i, 512, true)
	else:
		var active: int = 0 if G.playerAlive[0] else 1
		_set_player_viewport(active, 1024, true)
		_set_player_viewport(1 - active, 0, false)


func _set_player_viewport(index: int, width: int, view_visible: bool) -> void:
	viewport[index].size.x = width
	player_bar[index].visible = view_visible
	viewport_container[index].visible = view_visible


func connet_camera_to_player() -> void:
	for i: int in player.size():
		var player_node: Player = get_tree().get_nodes_in_group("Player_%d" % i).front()
		player[i] = player_node
		
		var remote_transform: RemoteTransform2D = RemoteTransform2D.new()
		remote_transform.remote_path = camera[i].get_path()
		player_node.add_child(remote_transform)


func on_health_value_changed(player_number: int, health_value: float) -> void:
	var bar: progressBar = hp_bar[player_number]
	if health_value == 100:
		bar.set_value_int(health_value)
	else:
		bar.set_percent_value_int(health_value)


func on_mana_value_changed(player_number: int, mana_value: float) -> void:
	var bar: progressBar = mana_bar[player_number]
	if mana_value >= 99:
		bar.set_value_int(mana_value)
	else:
		bar.set_percent_value_int(mana_value)
