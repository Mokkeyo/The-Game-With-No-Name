extends Menu
class_name Controlls

var player: int = 0
var previous_device: String
var waiting_for_input: bool = false
var mouse_position: Vector2

@onready var canvas_layer: Control = $CanvasLayer
@onready var assign_controller_btn: Button = $ControllButtons/AssignController
@onready var player_controlls_label: Label = $PlayerControlls/PlayerLabel

var player_inputs: Array[String] = ["_up", "_down", "_left", "_right", "_jump", "_attack", "_wand", "_interact", "_spawn"]

@onready var controller_inputs: Array[CInputButton] = [
		$ControllerButtons/UpButton, $ControllerButtons/DownButton, $ControllerButtons/LeftButton, $ControllerButtons/RightButton, $ControllerButtons/JumpButton,
		$ControllerButtons/AttackButton, $ControllerButtons/WandButton, $ControllerButtons/InteractButton,
		$ControllerButtons/SpawnButton
		]

@onready var keyboard_inputs: Array[KInputButton] = [
		$KeyButtons/UpButton, $KeyButtons/DownButton, $KeyButtons/LeftButton, $KeyButtons/RightButton, 
		$KeyButtons/JumpButton, $KeyButtons/AttackButton, $KeyButtons/WandButton, $KeyButtons/InteractButton,
		$KeyButtons/SpawnButton
		]

func _unhandled_input(event: InputEvent) -> void:
	if not waiting_for_input:
		super._unhandled_input(event)
		
	if Input.is_action_just_pressed("escape"):
		reset_controller_assignment()
		var timer: Timer = Timer.new()
		add_child(timer)
		timer.start(0.1)
		await timer.timeout
		waiting_for_input = false
		timer.queue_free()
		return
		
	if event.is_pressed() and event is InputEventJoypadButton:
		handle_controller_assignment(event.device)


func handle_controller_assignment(device: int) -> void:
	var temp_player: int = player -1
	var previous: int = G.SavedInputMap.device[player]
	var other_player: int = 1 - temp_player
	
	G.SavedInputMap.device[temp_player] = device
	
	if G.SavedInputMap.device[other_player] == device:
		G.SavedInputMap.device[other_player] = previous

	G.save_inputs()
	reset_controller_assignment()


func reset_controller_assignment() -> void:
	canvas_layer.visible = false


func change_input_device(device_name: String) -> void:
	if not previous_device == device_name:
		previous_device = device_name
		for input_btn: CInputButton in controller_inputs:
			input_btn.input_device = device_name
			input_btn.display_key()


func changePlayer(current_player: int) -> void:
	player = current_player
	var other_player: int = 1 - current_player
	var backgrounds: Array[Panel] = [$PlayerControlls/Player1Background, $PlayerControlls/Player2Background]
	var buttons: Array[Button] = [$ControllButtons/Player1Button, $ControllButtons/Player2Button]
	
	buttons[current_player].disabled = true
	buttons[other_player].disabled = false
	backgrounds[current_player].visible = true
	backgrounds[other_player].visible = false
	player_controlls_label.text = "Player %d Controlls" % (current_player + 1)
	display_key()


func display_key() -> void:
	var player_prefix: String = "player%d" % (player + 1)
	for i: int in player_inputs.size():
		var action: String = str(player_prefix, player_inputs[i])
		controller_inputs[i].action = "C-" + action
		controller_inputs[i].display_key()
		keyboard_inputs[i].action = action
		keyboard_inputs[i].display_key()


func disable_all_buttons(disable: bool) -> void:
	if disable:
		mouse_position = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if disable else Input.MOUSE_MODE_VISIBLE
	if not disable:
		Input.warp_mouse(mouse_position)


func add_event(event: InputEvent, index: int) -> void:
	var action_name: StringName = "player%d%s" % [player + 1, player_inputs[index]]
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	G.SavedInputMap.inputMap[action_name] = event


func restore_default_bindings() -> void:
	var defaults: Array[Array] = [
		[KEY_W, KEY_S, KEY_A, KEY_D, KEY_SPACE, MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, KEY_SHIFT, KEY_Q],
		[KEY_T, KEY_G, KEY_F, KEY_H, KEY_UP, KEY_LEFT, KEY_RIGHT, KEY_DOWN, KEY_R]
	]
	
	for i: int in defaults[player].size():
		if i >= 5 and i <= 6 and player == 0:
			var ev: InputEventMouseButton
			ev = InputEventMouseButton.new()
			ev.button_index = defaults[player][i]
			add_event(ev, i)
		else:
			var ev: InputEventKey
			ev = InputEventKey.new()
			ev.keycode = defaults[player][i]
			add_event(ev, i)
	
	display_key()
	G.save_inputs()


func _on_assign_controller_pressed() -> void:
	canvas_layer.visible = true
	assign_controller_btn.disabled = true
	assign_controller_btn.grab_focus()


func _on_restore_default_pressed() -> void:
	restore_default_bindings()


func _on_player_1_button_pressed() -> void: changePlayer(0)
func _on_player_2_button_pressed() -> void: changePlayer(1)
