extends CheckBox
class_name PrintFpsButton

func _ready() -> void:
	start()


func start() -> void:
	button_pressed = G.save_stat_inf.printFps


func _on_toggled(toggled_on: bool) -> void:
	G.save_stat_inf.printFps = toggled_on
	G.save_options()
