extends ColorRect
class_name Fader

@onready var kristall_text: int
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var secretText: Sprite2D = $SecretText

func _ready() -> void:
	secretText.visible = false

func secret_text() -> void:
	if not kristall_text == 0:
		secretText.frame = kristall_text - 1
		secretText.visible = true

func fade_in() -> AnimationPlayer:
	get_tree().paused = false
	animationPlayer.play("fade_in")
	return animationPlayer

func fade_out() -> AnimationPlayer:
	get_tree().paused = true
	secret_text()
	animationPlayer.play("fade_out")
	return animationPlayer
