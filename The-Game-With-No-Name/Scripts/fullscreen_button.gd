extends MenuCheckBox
class_name FullscreenButton

func _ready() -> void:
	super._ready()
	button_pressed = Save.options.fullscreen
	G.fullscreen_changed.connect(toggle_button)

func _on_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	Save.options.fullscreen = button_pressed
	Save.save_options()
	G.fullscreen_changed.emit()


func toggle_button() -> void:
	button_pressed = Save.options.fullscreen
