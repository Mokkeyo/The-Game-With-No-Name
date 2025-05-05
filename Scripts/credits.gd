extends Node2D

var code: int = 0
@onready var achievmentComponent: AchievmentComponent = $achievmentComponent
@onready var timer: Timer = $Timer
@onready var konamiPlayer: AnimationPlayer = $KonamiPlayer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var button: Button = $Button

var inputs: Array[String] = ["oben", "oben", "unten", "unten", "links", "rechts", "links", "rechts", "B", "A"]

func _ready() -> void:
	animationPlayer.play("default")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(inputs[code]):
		timer.start()
		code += 1
		if code > inputs.size():
			code = 0
			konamiPlayer.play("Konami")
			achievmentComponent.add_achievment()
	elif code > 0 and not timer.is_stopped():
		code = 0

func _on_AnimationPlayer_animation_finished(_default: String) -> void:
	button.grab_focus()

func _on_Button_pressed() -> void:
	get_tree().change_scene_to_file("res://Szenen/MainMenu.tscn")
	SoundMusic.play_underground()
	G.SaveStat.levelNumber = 1
	G.save_data()

func _on_Timer_timeout() -> void:
	code = 0
