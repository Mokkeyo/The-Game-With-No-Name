extends Menu
class_name Controlls

var player: int = 0
var previous_device: String
var mouse_position: Vector2

enum State {IDLE, CONTROLLER_ASSIGN, INPUT_MAPPING}
var state: State = State.IDLE

@onready var assign_ui: Control = $UI/AssignUI
@onready var assign_controller_btn: Button = $ControllButtons/AssignController
@onready var player_controlls_label: Label = $UI/PlayerControlls/PlayerLabel

var player_inputs: Array[String] = ["_up", "_down", "_left", "_right", "_jump", "_attack", "_wand", "_interact", "_spawn"]

var controller_inputs: Array[CInputButton] = []
var keyboard_inputs: Array[KInputButton] = []


func _ready() -> void:
	super._ready()
	var key_buttons: Control = $KeyButtons
	var controller_buttons: Control = $ControllerButtons
	for Ki: KInputButton in key_buttons.get_children():
		Ki.rebinding_started.connect(disable_all_buttons)
		Ki.remap_key.connect(remap_key)
		keyboard_inputs.append(Ki)
		
	for Ci: CInputButton in controller_buttons.get_children():
		Ci.rebinding_started.connect(disable_all_buttons)
		Ci.remap_key.connect(remap_key)
		controller_inputs.append(Ci)



func _unhandled_input(event: InputEvent) -> void:
	match state:
		State.IDLE:
			super._unhandled_input(event)
		State.CONTROLLER_ASSIGN:
			if not Input.is_action_just_pressed("escape"):
				return
			
			reset_controller_assignment()
			var timer: Timer = Timer.new()
			add_child(timer)
			timer.start(0.1)
			await timer.timeout
			state = State.IDLE
			timer.queue_free()
			return
		
	if event.is_pressed() and event is InputEventJoypadButton:
		handle_device_assignment(event.device)


func handle_device_assignment(device: int) -> void:
	InputSerializer.change_device_for_player(Save.inputs, player, device)
	InputSerializer.apply_inputmap_from_dict(Save.inputs)
	Save.save_inputs()
	reset_controller_assignment()


func reset_controller_assignment() -> void:
	assign_ui.visible = false


func change_input_device(device_name: String) -> void:
	if not previous_device == device_name:
		previous_device = device_name
		for input_btn: CInputButton in controller_inputs:
			input_btn.input_device = device_name
			input_btn.display_key()


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
			remap_key("player%d%s" % [player + 1, player_inputs[i]], ev, false)
		else:
			var ev: InputEventKey
			ev = InputEventKey.new()
			ev.keycode = defaults[player][i]
			remap_key("player%d%s" % [player + 1, player_inputs[i]], ev, false)
	display_key()
	Save.save_inputs()



func remap_key(action: String, event: InputEvent, save: bool = true) -> void:
	InputSerializer.set_inputs(Save.inputs, action, event)
	
	InputSerializer.apply_action_from_dict(Save.inputs, action)
	
	if save:
		Save.save_inputs()


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
	for i: int in controller_inputs.size():
		controller_inputs[i].player = current_player
	display_key()


func disable_all_buttons(disable: bool) -> void:
	state = State.INPUT_MAPPING if disable else State.IDLE
	if disable:
		mouse_position = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if disable else Input.MOUSE_MODE_VISIBLE
	if not disable:
		Input.warp_mouse(mouse_position)


func display_key() -> void:
	var player_prefix: String = "player%d" % (player + 1)
	for i: int in player_inputs.size():
		var action: String = str(player_prefix, player_inputs[i])
		controller_inputs[i].action = action
		controller_inputs[i].display_key()
		keyboard_inputs[i].action = action
		keyboard_inputs[i].display_key()


func _on_assign_controller_pressed() -> void:
	assign_ui.visible = true
	assign_controller_btn.disabled = true
	assign_controller_btn.grab_focus()


func _on_restore_default_pressed() -> void:
	restore_default_bindings()


func _on_player_1_button_pressed() -> void: changePlayer(0)
func _on_player_2_button_pressed() -> void: changePlayer(1)
