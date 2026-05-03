extends Button
class_name InputButton

signal rebinding_started(toggled: bool)
signal remap_key(action: String, device_index: int, event: InputEvent)

@export var action: String = ""
@export var device_index: int

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

func _init() -> void:
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	if FileAccess.file_exists(G.SAVE_PATH + G.SAVE_FILES["controls"]):
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
	if not G.saved_input_map.inputMap.has(action):
		G.saved_input_map.inputMap[action] = [null, null]
	var arr: Array = G.saved_input_map.inputMap[action]
	if arr.size() < 2:
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
		remap_key.emit(action, device_index, valid_event)
		display_key()
		timer.start()


func display_key() -> void:
	pass  # wird überschrieben

func _on_timer_timeout() -> void:
	button_pressed = false
