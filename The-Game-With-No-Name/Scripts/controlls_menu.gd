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
	var temp_player: int = player
	var previous: int = G.saved_input_map.device[player]
	var other_player: int = 1 - temp_player
	
	G.saved_input_map.device[temp_player] = device
	
	if G.saved_input_map.device[other_player] == device:
		G.saved_input_map.device[other_player] = previous

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
	for i: int in controller_inputs.size():
		controller_inputs[i].player = current_player
	display_key()


func remap_key(action: String, device_index: int, event: InputEvent, save: bool = true) -> void:
	if not G.saved_input_map.inputMap.has(action):
		G.saved_input_map.inputMap[action] = [null, null]
	if G.saved_input_map.inputMap[action].size() < 2:
		G.saved_input_map.inputMap[action].resize(2)
	G.saved_input_map.inputMap[action][device_index] = event
	
	var arr: Array = G.saved_input_map.inputMap[action]
	
	InputMap.action_erase_events(action)
	for ev:  InputEvent in arr:
		if ev:
			InputMap.action_add_event(action, ev)
	if save:
		G.save_inputs()


func disable_all_buttons(disable: bool) -> void:
	waiting_for_input = disable
	if disable:
		mouse_position = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if disable else Input.MOUSE_MODE_VISIBLE
	if not disable:
		Input.warp_mouse(mouse_position)


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
			remap_key("player%d%s" % [player + 1, player_inputs[i]], 0, ev, false)
		else:
			var ev: InputEventKey
			ev = InputEventKey.new()
			ev.keycode = defaults[player][i]
			remap_key("player%d%s" % [player + 1, player_inputs[i]], 0, ev, false)
	display_key()
	G.save_inputs()


func display_key() -> void:
	var player_prefix: String = "player%d" % (player + 1)
	for i: int in player_inputs.size():
		var action: String = str(player_prefix, player_inputs[i])
		controller_inputs[i].action = action
		controller_inputs[i].display_key()
		keyboard_inputs[i].action = action
		keyboard_inputs[i].display_key()


func _on_assign_controller_pressed() -> void:
	canvas_layer.visible = true
	assign_controller_btn.disabled = true
	assign_controller_btn.grab_focus()


func _on_restore_default_pressed() -> void:
	restore_default_bindings()


func _on_player_1_button_pressed() -> void: changePlayer(0)
func _on_player_2_button_pressed() -> void: changePlayer(1)
