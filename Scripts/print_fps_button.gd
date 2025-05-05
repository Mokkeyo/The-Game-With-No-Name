extends CheckBox
class_name PrintFpsButton

func _ready() -> void:
	start()


func start() -> void:
	button_pressed = G.SaveStatInf.printFps


func _on_toggled(toggled_on: bool) -> void:
	G.SaveStatInf.printFps = toggled_on
	G.save_options()
