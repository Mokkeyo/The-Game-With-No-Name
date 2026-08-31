extends OptionButton
class_name MenuOptionButton

func _ready() -> void:
    pressed.connect(AudioManager.play_ui_sfx.bind(Sounds.BUTTON_PRESSED))
    pressed.connect(grab_focus)