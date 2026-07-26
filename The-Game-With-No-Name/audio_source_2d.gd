extends Node2D
class_name AudioSource2D

@export var sound: SoundEffect
@export var activation_distance: float = 300.0

func _ready() -> void:
	if sound == null:
		return
	
	AudioManager.register_source(self)


func _exit_tree() -> void:
	AudioManager.unregister_source(self)
