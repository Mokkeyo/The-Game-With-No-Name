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

@onready var panel: Panel = $Panel
var player: Array[Player] = [null, null]


func _ready() -> void:
	for i: int in G.save_stat.playerHp.size():
		viewport[i].render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE


func add_level(currentLevel: Node2D) -> void:
	viewport[0].add_child(currentLevel)
	viewport[1].world_2d = viewport[0].world_2d


func set_viewport_size(player_alive: Array[bool]) -> void:
	if player_alive.size() < 2:
		push_warning("Player alive size is < 2")
		return
	
	panel.visible = player_alive[0] and player_alive[1]
	
	if panel.visible:
		for i: int in player.size():
			_set_player_viewport(i, 512, true)
	else:
		var active: int = 0 if player_alive[0] else 1
		_set_player_viewport(active, 1024, true)
		_set_player_viewport(1 - active, 0, false)


func _set_player_viewport(index: int, width: int, view_visible: bool) -> void:
	viewport[index].size.x = width
	viewport_container[index].visible = view_visible


func connet_camera_to_player() -> void:
	for i: int in player.size():
		var remote_transform: RemoteTransform2D = RemoteTransform2D.new()
		remote_transform.remote_path = camera[i].get_path()
		player[i].add_child(remote_transform)
