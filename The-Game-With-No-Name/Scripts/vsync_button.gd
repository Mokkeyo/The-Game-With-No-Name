extends MenuCheckBox
class_name  VsyncButton

func _ready() -> void:
	super._ready()
	start()


func start() -> void:
	button_pressed = Save.options.vsync


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Save.options.vsync = button_pressed
	Save.save_options()
