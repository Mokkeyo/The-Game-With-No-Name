extends HSlider
class_name VolumeSlider

var start_time: float = 1
var time_left: float = start_time
@export_enum("musicVolume", "SfxVolume", "MaxVolume") var volume: int

func _ready() -> void:
	start()

func start() -> void:
	if volume == 0:
		value = Save.options.musicVolume
		set_bus_volume("Music", value)
	elif volume == 1:
		value = Save.options.sfxVolume
		set_bus_volume("SFX", value)
	else:
		value = Save.options.maxVolume
		set_bus_volume("Master", value)

func _on_value_changed(_value: float) -> void:
	if volume == 0:
		Save.options.musicVolume = value
		set_bus_volume("Music", value)
	elif volume == 1:
		Save.options.sfxVolume = value
		set_bus_volume("SFX", value)
	else:
		Save.options.maxVolume = value
		set_bus_volume("Master", value)
	
	Save.save_options()


func set_bus_volume(bus_name: String, s_value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	var s_volume: float = max(s_value, 0.001)
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(s_volume))
