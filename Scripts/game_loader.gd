extends Node2D
@onready var startPlayer: AnimationPlayer = $StartPlayer
@onready var controllerPlayer: AnimationPlayer = $ControllerPlayer
@onready var instruction: Node2D = $Instruction
var main_menu: String = "res://Scenes/main_menu.tscn"

func _ready() -> void:
	G.load_options()
	G.load_inputs()
	controllerPlayer.play("Controller")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		instruction.visible = false
		get_tree().change_scene_to_file(main_menu)

func _on_controller_player_animation_finished(_anim_name: StringName) -> void:
	startPlayer.play("start")

func _on_start_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file(main_menu)
