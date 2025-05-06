extends HSlider
class_name VolumeSlider

var start_time: float = 1
var time_left: float = start_time
@export_enum("musicVolume", "SfxVolume", "MaxVolume") var volume: int

func _ready() -> void:
	start()

func start() -> void:
	if volume == 0:
		value = G.SaveStatInf.musicVolume
	elif volume == 1:
		value = G.SaveStatInf.sfxVolume
	else:
		value = G.SaveStatInf.maxVolume

func _on_value_changed(_value: float) -> void:
	if volume == 0:
		G.SaveStatInf.musicVolume = value
	elif volume == 1:
		G.SaveStatInf.sfxVolume = value
	else:
		G.SaveStatInf.maxVolume = value
	SoundMusic.chance_sound_volume(value)
	G.save_options()
