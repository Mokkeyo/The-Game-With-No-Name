extends HSlider
class_name VolumeSlider

var start_time: float = 1
var time_left: float = start_time
@export_enum("musicVolume", "SfxVolume", "MaxVolume") var volume: int

func _ready() -> void:
	start()

func start() -> void:
	if volume == 0:
		value = G.save_stat_inf.musicVolume
	elif volume == 1:
		value = G.save_stat_inf.sfxVolume
	else:
		value = G.save_stat_inf.maxVolume

func _on_value_changed(_value: float) -> void:
	if volume == 0:
		G.save_stat_inf.musicVolume = value
	elif volume == 1:
		G.save_stat_inf.sfxVolume = value
	else:
		G.save_stat_inf.maxVolume = value
	SoundMusic.chance_sound_volume(value)
	G.save_options()
