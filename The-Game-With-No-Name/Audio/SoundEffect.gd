extends Resource
class_name SoundEffect

@export var streams: Array[AudioStream] = []

@export_enum("SFX", "Music", "Ambient", "UI") 
var bus: String = "SFX"

@export_range(-80.0, 24.0, 0.1)
var volume_db: float = 0.0

@export var random_pitch: bool = true
@export_range(0.0, 0.5, 0.01)
var pitch_variation: float = 0.05

@export var spatial: bool = false
