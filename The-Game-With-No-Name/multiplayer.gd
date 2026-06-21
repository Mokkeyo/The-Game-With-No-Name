extends Node

const NORAY_ADRESS: String = "tomfol.io"
const NORAY_PORT: int = 8890

var is_host: bool = false

#func _ready() -> void:
#	Noray.on_connect_to_host.connect(on_noray_connected)
	
#	Noray.connect_to_host(NORAY_ADRESS, NORAY_PORT)


func on_noray_connected() -> void:
	print("Connected to Noray server")
	
#	Noray.register_host()
#	await Noray.on_pid
#	await Noray.register_remote()


func host() -> void:
	print("Hosting")
	
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
#	peer.create_server(Noray.local_port)
	multiplayer.multiplayer_peer = peer
	is_host = true

func join() -> void:
	return
