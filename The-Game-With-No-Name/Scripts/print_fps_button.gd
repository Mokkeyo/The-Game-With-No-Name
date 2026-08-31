extends MenuCheckBox
class_name PrintFpsButton

func _ready() -> void:
	super._ready()
	start()


func start() -> void:
	button_pressed = Save.options.printFps


func _on_toggled(toggled_on: bool) -> void:
	Save.options.printFps = toggled_on
	Save.save_options()
