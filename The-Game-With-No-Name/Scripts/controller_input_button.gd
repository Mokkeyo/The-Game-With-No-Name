extends InputButton
class_name CInputButton

const CONTROLLER: int = 1

var input_device: String = "Playstation"
var player: int = 1
var deadzone: float = 0.8
var pattern: RegEx = RegEx.new()

static var texture_cache: Dictionary = {}

func _ready() -> void:
	device_index = CONTROLLER
	set_process_unhandled_input(false)
	pattern.compile(r"\d+")
	super._ready()
 

func _toggled(toggled_on: bool) -> void:
	super._toggled(toggled_on)
	set_process_unhandled_input(toggled_on)


func _unhandled_input(event: InputEvent) -> void:
	process_event(event)


func handle_input(event: InputEvent) -> InputEvent:
	
	var device_id: int = Save.inputs[action][1]["device"]
	
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



func get_tex(path: String) -> Texture2D:
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]


func display_key() -> void:
	var event: InputEvent = InputSerializer.get_event_from_action(Save.inputs, action, CONTROLLER)
	if not event:
		sprite.visible = false
		text = ""
		return
	
	
	var input_name :String = event.as_text()
	var result: RegExMatch = pattern.search(input_name)
	
	var number: int = -1
	if result:
		number = result.get_string().to_int()
	
	var special_button: bool = input_name.begins_with("Joypad Button") and (number < 4 or (number > 8 and number < 11))
	var special_motion: bool = input_name.begins_with("Joypad Motion") and (number > 3)
	if special_button or special_motion:
		sprite.texture = get_tex("res://Button/%s/%s.png" % [input_device, input_name])
	else:
		sprite.texture = get_tex("res://Button/%s.png" % [input_name])
		
	sprite.visible = true
