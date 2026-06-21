extends HSlider
class_name VolumeSlider

var start_time: float = 1
var time_left: float = start_time
enum Sound {MASTER, MUSIC, SFX, AMBIENT}

@export var sound: Sound

func _ready() -> void:
	start()

func start() -> void:
	
	match sound:
		Sound.MUSIC:
			value = Save.options.musicVolume
			set_bus_volume("Music", value)
		Sound.SFX:
			value = Save.options.sfxVolume
			set_bus_volume("SFX", value)
		Sound.AMBIENT:
			value = Save.options.ambientVolume
			set_bus_volume("Ambient", value)
		Sound.MASTER:
			value = Save.options.maxVolume
			set_bus_volume("Master", value)

func _on_value_changed(_value: float) -> void:
	match sound:
		Sound.MASTER:
			Save.options.maxVolume = value
			set_bus_volume("Master", value)
		Sound.MUSIC:
			Save.options.musicVolume = value
			set_bus_volume("Music", value)
		Sound.SFX:
			Save.options.sfxVolume = value
			set_bus_volume("SFX", value)
		Sound.AMBIENT:
			Save.options.ambientVolume = value
			set_bus_volume("Ambient", value)
	
	Save.save_options()


func set_bus_volume(bus_name: String, s_value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	var s_volume: float = max(s_value, 0.001)
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(s_volume))
