extends CheckBox
class_name FullscreenButton

func _ready() -> void:
	button_pressed = G.SaveStatInf.fullscreen
	G.fullscreen_changed.connect(toggle_button)

func _on_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	G.SaveStatInf.fullscreen = button_pressed
	G.save_options()
	G.emit_signal("fullscreen_changed")


func toggle_button() -> void:
	button_pressed = G.SaveStatInf.fullscreen
