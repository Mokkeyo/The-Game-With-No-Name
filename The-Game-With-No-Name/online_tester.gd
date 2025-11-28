extends Node

const PLAYER: PackedScene = preload("res://Player/Scenes/player_online.tscn")
@onready var marker: Marker2D = $Marker2D
@onready var ui: Control = $CanvasLayer/HostJoin
@onready var exit_ui: Control = $CanvasLayer/Control

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _on_host_button_pressed() -> void:
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	
	ui.hide()
	exit_ui.show()
	
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(
			func(pid: int) -> void:
				print("Peer connected: ", pid )
				add_player(pid)
		)
	
	
	multiplayer.peer_disconnected.connect(
		func(pid: int) -> void:
			print("Peer disconneted: ", pid)
			remove_player(pid)
	)
	
	add_player(multiplayer.get_unique_id())


func _on_join_button_pressed() -> void:
	peer.create_client("localhost", 25565)
	multiplayer.multiplayer_peer = peer
	
	ui.hide()
	exit_ui.show()
	
	multiplayer.connection_failed.connect(
		func() -> void:
			print("Keine Verbindung möglich")
			join_failed()
	)
	
	multiplayer.server_disconnected.connect(
		func() -> void:
			stop_connection()
			get_tree().reload_current_scene()
	)


func add_player(pid: int) -> void:
	print("Add player called on server? ", multiplayer.is_server())
	if has_node(str(pid)):
		return
	
	var player: Player_Online = PLAYER.instantiate()
	player.name = str(pid)
	add_child(player)
	
	if pid == multiplayer.get_unique_id():
		# Host-Spieler → lokal initialisieren, kein RPC nötig
		player.remote_init(marker.global_position, 0 if (pid == 1) else 1)
	else:
		# Client → sende RPC
		player.rpc_id(pid, "remote_init", marker.global_position, 0 if (pid == 1) else 1)


func remove_player(pid: int) -> void:
	var s_pid: String = str(pid)
	if has_node(s_pid):
		get_node(s_pid).queue_free()


func _on_exit_server_pressed() -> void:
	stop_connection()
	get_tree().reload_current_scene()


func stop_connection() -> void:
	multiplayer.multiplayer_peer = null
	
	if peer:
		peer.close()
	
	print("verbindung geschlossen")


func join_failed() -> void:
	stop_connection()
	get_tree().reload_current_scene()


func _exit_tree() -> void:
	stop_connection()
