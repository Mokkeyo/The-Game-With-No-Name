extends Button
class_name CInputButton

@export var action: String = "ui_up"
@export var controlls_menu: Controlls

var input_device: String = "Playstation"
var player: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

var deadzone: float = 0.8
var pattern: RegEx = RegEx.new()

func _init() -> void:
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready() -> void:
	set_process_unhandled_input(false)
	pattern.compile(r"\d+")
	if FileAccess.file_exists(G.SAVE_PATH + G.SAVE_FILES["controls"]):
		display_key()
 

func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	controlls_menu.disable_all_buttons(toggled_on)
	
	if toggled_on:
		text = ". . ."
		release_focus()
	else: 
		grab_focus()
		
	sprite.visible = not toggled_on
	controlls_menu.waiting_for_input = toggled_on


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		display_key()
		timer.start()
		return
	
	var input_event: InputEvent = check_for_input_event(event)
	
	if input_event:
		remap_key(input_event)
		G.saved_input_map.inputMap[action][1] = input_event
		G.save_inputs()
		timer.start()


func check_for_input_event(event: InputEvent) -> InputEvent:
	if not event: 
		return null
	
	var current_player: int = controlls_menu.player
	var device_id: int = G.saved_input_map.device[current_player]
	
	match event:
		InputEventJoypadMotion:
			var motion: InputEventJoypadMotion = event as InputEventJoypadMotion
			if motion.device == device_id and abs(motion.axis_value) > deadzone:
				var e: InputEventJoypadMotion = motion.duplicate() as InputEventJoypadMotion
				e.axis_value = sign(motion.axis_value)
				return e
		InputEventJoypadButton:
			if event.device == device_id and event.is_pressed():
				return event
	
	return null


func remap_key(event: InputEvent) -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	
	events[1] = event
	
	InputMap.action_erase_events(action)
	
	for ev: InputEvent in events:
		if ev:
			InputMap.action_add_event(action, ev)
	
	display_key()


func display_key() -> void:
	var events : Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		sprite.visible = false
		text = ""
		return
	
	
	var input_name :String = events[1].as_text()
	var result: RegExMatch = pattern.search(input_name)
	
	var number: int = -1
	if result:
		number = result.get_string().to_int()
	
	var special_button: bool = input_name.begins_with("Joypad Button") and (number < 4 or (number > 8 and number < 11))
	var special_motion: bool = input_name.begins_with("Joypad Motion") and (number > 3)
	
	if special_button or special_motion:
		sprite.texture = load("res://Button/%s/%s.png" % [input_device, input_name])
	else:
		sprite.texture = load("res://Button/%s.png" % [input_name])
		
	sprite.visible = true


func _on_timer_timeout() -> void:
	button_pressed = false
