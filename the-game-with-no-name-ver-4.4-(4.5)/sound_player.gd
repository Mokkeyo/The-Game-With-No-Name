extends AudioStreamPlayer2D
class_name SoundPlayer

func _ready() -> void:
	randomize()

func play_sound() -> void:
	pitch_scale = randf_range(0.95, 1.05)
	play()
