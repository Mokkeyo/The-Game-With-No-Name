extends Node2D
class_name Credits

var code_index: int = 0
@onready var achievmentComponent: AchievmentComponent = $achievmentComponent
@onready var timer: Timer = $Timer
@onready var konamiPlayer: AnimationPlayer = $KonamiPlayer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var button: Button = $Button

const KONAMI_CODE: Array = [
	KEY_UP,
	KEY_UP,
	KEY_DOWN,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_B,
	KEY_A
]

func _ready() -> void:
	animationPlayer.play("default")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_event: InputEventKey = event
		
		
		if not key_event.keycode == KONAMI_CODE[code_index]:
			code_index = 0
			return
		
		code_index += 1
		timer.start()
		
		if code_index >= KONAMI_CODE.size():
			code_index = 0
			timer.stop()
			achievmentComponent.add_achievment()
			konamiPlayer.play("Konami")
			

func _on_AnimationPlayer_animation_finished(_default: String) -> void:
	button.grab_focus()

func _on_Button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	Save.player.levelNumber = 1
	Save.save_data(Save.active_slot)

func _on_Timer_timeout() -> void:
	code_index = 0
