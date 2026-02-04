extends Node
class_name RespawnManager

@export var respawn_time: float = 2.0

var timer: Timer = Timer.new()
var player_manager: PlayerManager

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)

func start() -> void:
	timer.start(respawn_time)

func _on_timeout() -> void:
	G.respawn_allowed.emit()
