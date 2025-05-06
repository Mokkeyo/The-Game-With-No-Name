extends CheckBox
class_name  VsyncButton

func _ready() -> void:
	start()


func start() -> void:
	button_pressed = G.SaveStatInf.vsync


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	G.SaveStatInf.vsync = button_pressed
	G.save_options()
