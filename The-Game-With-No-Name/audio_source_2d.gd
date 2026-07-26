extends Node2D
class_name AudioSource2D

@export var sound: SoundEffect
@export var fade_time: float = 1.0
@export var activation_distance: float = 300.0

@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var fade_tween: Tween


func _ready() -> void:
	if sound == null:
		return
	
	print("ambient sound ", get_world_2d())
	AudioManager.setup_player(player, sound)
	AudioManager.register_source(self)


func _exit_tree() -> void:
	AudioManager.unregister_source(self)


func playback_position() -> float:
	return player.get_playback_position()


func play(p: float = 0.0) -> void:
	_cancel_fade()

	player.stop()
	player.volume_db = sound.volume_db
	player.play(p)


func fade_in(p: float = 0.0) -> void:
	_cancel_fade()

	player.stop()
	player.volume_db = AudioManager.SILENT_DB
	player.play(p)

	fade_tween = create_tween()

	fade_tween.tween_property(
		player,
		"volume_db",
		sound.volume_db,
		fade_time
	)


func fade_out() -> void:
	_cancel_fade()

	fade_tween = create_tween()

	fade_tween.tween_property(
		player,
		"volume_db",
		AudioManager.SILENT_DB,
		fade_time
	)

	await fade_tween.finished

	player.stop()
	player.volume_db = sound.volume_db

	fade_tween = null


func stop() -> void:
	_cancel_fade()

	player.stop()
	player.volume_db = sound.volume_db


func _cancel_fade() -> void:
	if fade_tween:
		fade_tween.kill()
		fade_tween = null
