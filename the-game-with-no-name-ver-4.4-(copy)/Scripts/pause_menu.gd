extends Control
class_name PauseMenu

@onready var paused: Control = $Paused 
@onready var continueButton: Button = $Paused/Continue
@onready var nothingButton: Button = $NothingButton

@export var menus: Array[Menu]

var can_pause: bool = true

func _ready() -> void:
	visible = false
	for i: int in menus.size():
		menus[i].visible = false
		menus[i].exited.connect(Callable(self, "to_start_menu").bind(i))


func _unhandled_input(_event: InputEvent) -> void:
	if can_pause:
		if Input.is_action_just_pressed("start") and not get_tree().paused:
			get_tree().paused = true
			visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			continueButton.grab_focus()
			return
			
		elif Input.is_action_just_pressed("escape"):
			exit_pause()


func to_start_menu(index: int) -> void:
	await start_tween(paused, menus[index])
	continueButton.grab_focus()
	set_process_unhandled_input(true)


func change_menu(index: int) -> void:
	set_process_unhandled_input(false)
	await start_tween(menus[index], paused)
	menus[index].enter()


func start_tween(going_to_zero: Control, active_menu: Control) -> void:
	nothingButton.grab_focus()
	going_to_zero.visible = true
	var tween: Tween = create_tween()
	var route: Vector2 = -going_to_zero.global_position
	tween.set_parallel(true)
	tween.tween_property(going_to_zero, "global_position", Vector2(0, 0), 0.4)
	tween.tween_property(active_menu, "global_position",route, 0.4)
	await tween.finished
	active_menu.visible = false


func exit_pause() -> void:
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		var timer: Timer = Timer.new()
		add_child(timer)
		timer.start(0.05)
		await timer.timeout
		timer.queue_free()
		get_tree().paused = false
		visible = false


func _on_controlls_pressed() -> void: change_menu(0)
func _on_options_pressed() -> void: change_menu(1)
func _on_pokal_pressed() -> void: change_menu(2)
func _on_player_pressed() -> void: change_menu(3)


func _on_return_to_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn" if not G.battle_mode else "res://Scenes/battle_mode_menu.tscn")


func _on_continue_pressed() -> void:
	exit_pause()
