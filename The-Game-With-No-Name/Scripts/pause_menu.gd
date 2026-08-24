extends Control
class_name PauseMenu

const MENU_TWEEN_DURATION: float = 0.4
const PAUSE_DELAY: float = 0.05

@onready var paused_menu: Control = $Paused 
@onready var continue_button: Button = $Paused/Continue
@onready var focus_blocker: Button = $NothingButton

var is_transitioning: bool = false

@export var menus: Array[Menu]

func _ready() -> void:
	visible = false
	for i: int in menus.size():
		var menu: Menu = menus[i]
		menu.visible = false
		menu.exited.connect(_on_menu_exited.bind(i))


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("start") and not get_tree().paused:
		open_pause_menu()
		return
		
	if Input.is_action_just_pressed("escape"):
		exit_pause()


func open_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	continue_button.grab_focus()


func exit_pause() -> void:
	if not get_tree().paused:
		return
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	await get_tree().create_timer(PAUSE_DELAY).timeout
	
	get_tree().paused = false
	visible = false


func change_menu(index: int) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	set_process_unhandled_input(false)
	
	await switch_menu(menus[index], paused_menu)
	menus[index].enter()


func _on_menu_exited(index: int) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	await switch_menu(paused_menu, menus[index])
	
	continue_button.grab_focus()
	set_process_unhandled_input(true)


func switch_menu(from: Control, to: Control) -> void:
	focus_blocker.grab_focus()
	
	from.visible = true
	
	var tween: Tween = create_tween()
	tween.set_parallel()
	
	var from_position: Vector2 = from.global_position
#	var to_position: Vector2 = to.global_position
	
	tween.tween_property(
		from,
		"global_position",
		Vector2.ZERO,
		MENU_TWEEN_DURATION
	)
	
	tween.tween_property(
		to,
		"global_position",
		-from_position,
		MENU_TWEEN_DURATION
	)
	
	await tween.finished
	is_transitioning = false
	to.visible = false


func _on_controlls_pressed() -> void: change_menu(0)
func _on_options_pressed() -> void: change_menu(1)
func _on_pokal_pressed() -> void: change_menu(2)
func _on_player_pressed() -> void: change_menu(3)


func _on_return_to_main_menu_pressed() -> void:
	get_tree().paused = false
	if not BattleData.battle:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/battle_mode_menu.tscn")

func _on_continue_pressed() -> void:
	exit_pause()
