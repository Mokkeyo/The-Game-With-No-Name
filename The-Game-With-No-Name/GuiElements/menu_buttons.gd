extends Button
class_name Menu_Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if is_inside_tree():
		grab_focus()
	AudioManager.play_ui_sfx(Sounds.BUTTON_PRESSED)
