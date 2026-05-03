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
		set_bus_volume("Music", value)
	elif volume == 1:
		value = G.save_stat_inf.sfxVolume
		set_bus_volume("SFX", value)
	else:
		value = G.save_stat_inf.maxVolume
		set_bus_volume("Master", value)

func _on_value_changed(_value: float) -> void:
	if volume == 0:
		G.save_stat_inf.musicVolume = value
		set_bus_volume("Music", value)
	elif volume == 1:
		G.save_stat_inf.sfxVolume = value
		set_bus_volume("SFX", value)
	else:
		G.save_stat_inf.maxVolume = value
		set_bus_volume("Master", value)
	
	G.save_options()


func set_bus_volume(_bus_name: String, _s_value: float) -> void:
	pass
#	var bus_index: int = AudioServer.get_bus_index(bus_name)
#	AudioServer.set_bus_volume_db(bus_index, linear_to_db(s_value))
