extends AudioStreamPlayer2D
class_name SoundPlayer

@export var sound: String = ""

func _ready() -> void:
	randomize()

func play_sound() -> void:
	SoundMusic.play_sound(sound, get_parent() as Node2D)
