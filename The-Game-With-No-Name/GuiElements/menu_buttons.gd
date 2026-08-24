extends Button
class_name Menu_Button



func _on_pressed() -> void:
	AudioManager.play_ui_sfx(Sounds.BUTTON_PRESSED)
