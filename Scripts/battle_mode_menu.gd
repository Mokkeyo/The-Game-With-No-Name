extends Control
class_name BattleMenu

@onready var options: Menu = $Options
@onready var explanation: Menu = $explanation
@onready var controlls: Menu = $Controlls
@onready var arena_choose: Menu = $ArenaChoose

@onready var camera: Camera2D = $Camera2D
@onready var fader: Fader  = $Fader
@onready var main: Control = $Navigation
@onready var battle_button: Button = $Navigation/Battle
@onready var nothing_button: Button = $NothingButton


func _ready() -> void:
	camera.global_position = Vector2(0, 0)
	var animation_player: AnimationPlayer = fader.fade_in()
	await  animation_player.animation_finished
	if not G.battleReady[0] and not G.battleReady[1]:
		battle_button.grab_focus()

	var menus: Array[Menu] = [controlls, options, explanation, arena_choose]
	for menu: Menu in menus:
		menu.hide()
		menu.exited.connect(to_start_menu.bind(menu))


func to_start_menu(menu: Menu) -> void:
	await start_tween(main.global_position)
	menu.hide()
	battle_button.grab_focus()


func change_menu(menu: Menu) -> void:
	menu.show()
	await start_tween(menu.global_position)
	menu.enter()


func start_tween(final_position: Vector2) -> void:
	nothing_button.grab_focus()
	var tween: Tween = create_tween()
	tween.tween_property(camera, "global_position", final_position, 0.4)
	await tween.finished


func _on_battle_pressed() -> void: change_menu(arena_choose)
func _on_view_explanation_pressed() -> void: change_menu(explanation)
func _on_controlls_pressed() -> void: change_menu(controlls)
func _on_options_pressed() -> void: change_menu(options)


func _on_back_to_normal_mode_pressed() -> void:
	for i: int in range(G.battleReady.size()):
		G.battleReady[i] = false
	SoundMusic.play_underground()
	G.battle_mode = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
