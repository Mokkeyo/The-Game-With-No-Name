extends Control
@onready var main: Control = $Main
@onready var save_stats: SaveStatMenu = $SaveStats
@onready var options: Options = $Options
@onready var achievments: Achievments = $Achievments
@onready var controlls: Controlls = $Control
@onready var two_player_mode: TwoPlayerMode = $"2PlayerMode"

@onready var fader: Fader = $Fader
@onready var nothing_button: Button = $Main/NothingButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_button: Button = $Main/StartButton
@onready var quit_button: Button = $Main/QuitButton
@onready var camera: Camera2D = $Camera2D

var menus: Array[Menu]

func _ready() -> void:
	menus = [controlls, options, save_stats, achievments, two_player_mode]
	for menu: Menu in menus:
		menu.visible = false
		menu.exited.connect(to_start_menu.bind(menu))
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	G.playerAlive[1] = false
	G.playerAlive[0] = true
	
	animation_player.play("start")
	fader.visible = true
	fader.fade_in()
	
	await animation_player.animation_finished
	animation_player.play("creator_title")
	start_button.grab_focus()


func to_start_menu(menu: Menu) -> void:
	await start_tween(main.global_position)
	set_process_unhandled_input(true)
	menu.visible = false
	start_button.grab_focus()


func change_menu(menu: Menu) -> void:
	menu.visible = true
	await start_tween(menu.global_position)
	set_process_unhandled_input(false)
	menu.enter()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("back"):
		quit_button.grab_focus()


func start_tween(final_position: Vector2) -> void:
	nothing_button.grab_focus()
	var tween: Tween = create_tween()
	tween.tween_property(camera, "global_position", final_position, 0.4)
	await tween.finished


func _on_controll_button_pressed() -> void: change_menu(controlls)
func _on_option_button_pressed() -> void: change_menu(options)
func _on_start_button_pressed() -> void: change_menu(save_stats)
func _on_pokal_pressed() -> void: change_menu(achievments)
func _on_player_pressed() -> void: change_menu(two_player_mode)


func _on_battle_button_pressed() -> void:
	await fader.fade_out().animation_finished
	G.battle_mode = true
	SoundMusic.play_battle()
	get_tree().change_scene_to_file("res://Scenes/battle_mode_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
