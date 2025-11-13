extends Button
class_name CInputButton

@export var action: String = "ui_up"
@export var controlls_menu: Controlls

var input_device: String = "Playstation"
var player: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

func _init() -> void:
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready() -> void:
	set_process_unhandled_input(false)
	if FileAccess.file_exists(G.save_path + G.save_file_name[5]):
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
		G.SavedInputMap.inputMap[action] = input_event
		G.save_inputs()
		timer.start()


func check_for_input_event(event: InputEvent) -> InputEvent:
	if not event:
		return null
	
	var current_player: int = controlls_menu.player
	var device_id: int = G.SavedInputMap.device[current_player]
	
	if event is InputEventJoypadMotion:
		var motion: InputEventJoypadMotion = event
		if abs(motion.axis_value) > 0.8 and motion.device == device_id:
			motion.axis_value = 1 * sign(motion.axis_value)
			return motion
	
	elif event is InputEventJoypadButton:
		var button_event: InputEventJoypadButton = event
		if button_event.is_pressed() and button_event.device == device_id:
			return button_event
	
	return null


func remap_key(event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	display_key()


func display_key() -> void:
	text = ""
	
	var events : Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		sprite.visible = false
		return
	
	var input_name :String = events[0].as_text()
	
	var pattern: RegEx = RegEx.new()
	pattern.compile(r"\d+")
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
