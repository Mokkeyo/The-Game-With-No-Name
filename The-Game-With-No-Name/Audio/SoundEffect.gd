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

@export_range(1.0, 10000.0)
var max_distance: float = 200

@export_range(0.1, 10.0)
var attenuation: float = 1.0

@export var ambient_group: StringName

@export_range(1, 32)
var max_instances: int = 4

@export_range(0, 10)
var min_frame_interval: int = 1
