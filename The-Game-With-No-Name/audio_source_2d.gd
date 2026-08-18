extends Node2D
class_name AudioSource2D

@export var sound: SoundEffect = null
@export var activation_distance: float = 300.0

func _ready() -> void:
	await get_tree().process_frame
	AudioManager.register_source(self)


func _exit_tree() -> void:
	AudioManager.unregister_source(self)
