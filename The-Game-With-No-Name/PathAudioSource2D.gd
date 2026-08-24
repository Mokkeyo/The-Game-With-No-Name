extends Path2D
class_name PathAudioSource2D

@onready var audio_source: AudioSource2D = $AudioSource2D

@export var audio: SoundEffect

@export_category("Movement")
@export var update_interval: float = 0.05
@export var follow_speed: float = 8.0

var _timer: float = 0.0
var _target_position: Vector2

func _ready() -> void:
	audio_source.sound = audio
	_update_target()

func _process(delta: float) -> void:
	_timer -= delta
	
	if _timer <= 0.0:
		_timer = update_interval
		_update_target()
	
	if audio_source != null:
		audio_source.global_position = _target_position


func _update_target() -> void:
	if curve == null:
		return
	
	var player: Node2D = AudioManager.listener
	
	if player == null:
		return
	
	var local_player_position: Vector2 = to_local(player.global_position)
	var closest_point: Vector2 = curve.get_closest_point(local_player_position)
	_target_position = to_global(closest_point)
