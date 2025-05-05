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
	var players_alive: int = G.playerAlive.size()
	var both_alive: bool = G.playerAlive[0] and G.playerAlive[1]
	
	panel.visible = both_alive
	
	for i: int in players_alive:
		match [both_alive, G.playerAlive[i]]:
			[true, _]:
				_set_player_viewport(i, 512, true, true, Node.PROCESS_MODE_INHERIT)
			[false, true]:
				var other_player: int = 1 - i
				_set_player_viewport(i, 1024, true, true, Node.PROCESS_MODE_INHERIT)
				_set_player_viewport(other_player, 0, false, false, Node.PROCESS_MODE_DISABLED)
				camera[i].make_current()
			_:
				_set_player_viewport(i, 0, false, false, Node.PROCESS_MODE_DISABLED)


func _set_player_viewport(index: int, width: int, bar_visible: bool, container_visible: bool, process: Node.ProcessMode) -> void:
	viewport[index].size.x = width
	player_bar[index].visible = bar_visible
	viewport_container[index].visible = container_visible
	viewport[index].process_mode = process


func connet_camera_to_player() -> void:
	for i: int in player.size():
		var player_node: Player = get_tree().get_nodes_in_group("Player_%d" % i).front()
		var cam: Camera2D = camera[i]
		
		if cam.get_parent():
			cam.get_parent().remove_child(cam)
		
		player_node.add_child(cam)
		
		player[i] = player_node


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
