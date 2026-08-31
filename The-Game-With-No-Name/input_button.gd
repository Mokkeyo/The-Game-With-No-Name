extends Menu_Button
class_name InputButton

signal rebinding_started(toggled: bool)
signal remap_key(action: String, device_index: int, event: InputEvent)

@export var action: String = ""
@export var device_index: int

@onready var sprite: TextureRect = %TextureRect
@onready var timer: Timer = $Timer

func _init() -> void:
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready() -> void:
	super._ready()
	timer.timeout.connect(_on_timer_timeout)
	if FileAccess.file_exists(Save.SAVE_DIR + "inputs.json"):
		display_key()


func _toggled(toggled_on: bool) -> void:
	rebinding_started.emit(toggled_on)
	
	if toggled_on:
		text = ". . ."
		sprite.visible = false
		release_focus()
	else:
		grab_focus()


func get_key() -> Array:
	if not Save.inputs.has(action):
		return [null, null]
	
	var arr: Array = Save.inputs[action]
	
	if typeof(arr) != TYPE_ARRAY:
		return [null, null]
	
	if arr.size() < 2:
		arr = arr.duplicate()
		arr.resize(2)
	return arr


func handle_input(_event: InputEvent) -> InputEvent:
	return null


func process_event(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		display_key()
		timer.start()
		return
	
	var valid_event: InputEvent = handle_input(event)
	
	if valid_event:
#		action: String, event: InputEvent, save: bool = true
		remap_key.emit(action, valid_event, true)
		display_key()
		timer.start()


func display_key() -> void:
	pass

func _on_timer_timeout() -> void:
	button_pressed = false
