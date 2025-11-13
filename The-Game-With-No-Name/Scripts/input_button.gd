extends Button 
class_name KInputButton

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@export var action: String = "ui_up"
@export var controlls_menu: Controlls

var mouse_sprites: Dictionary = {
	MouseButton.MOUSE_BUTTON_LEFT: preload("res://Button/Left Mouse Button.png"),
	MouseButton.MOUSE_BUTTON_RIGHT: preload("res://Button/Right Mouse Button.png"),
	MouseButton.MOUSE_BUTTON_MIDDLE: preload("res://Button/Middle Mouse Button.png")
} 

func _init() -> void:
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready() -> void:
	set_process_input(false)
	if FileAccess.file_exists(G.SAVE_PATH + G.SAVE_FILES["controls"]):
		display_key()
 

func _toggled(toggled_on: bool) -> void:
	set_process_input(toggled_on)
	controlls_menu.waiting_for_input = toggled_on
	controlls_menu.disable_all_buttons(toggled_on)
	
	if toggled_on:
		text = ". . ."
		sprite.visible = false
		release_focus()
	else:
		grab_focus()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		display_key()
		timer.start()
		return
	
	if (event is InputEventMouseButton or event is InputEventKey) and event.is_pressed():
		remap_key(event)
		G.saved_input_map.inputMap[action][0] = event
		G.save_inputs()
		timer.start()


func remap_key(event: InputEvent) -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	
	events[0] = event
	
	InputMap.action_erase_events(action)
	
	for ev: InputEvent in events:
		if ev:
			InputMap.action_add_event(action, ev)
	
	display_key()


func display_key() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		sprite.visible = false
		text = ""
		return
	
	var ev: InputEvent = events[0]
	var key_input: InputEventKey = ev as InputEventKey
	
	if key_input:
		sprite.visible = false
		text = ev.as_text()
		return
	
	var mouse_input: InputEventMouse = ev as InputEventMouseButton
	
	if mouse_input:
		var mouse_ev: InputEventMouseButton = ev as InputEventMouseButton
		var tex: Texture2D = mouse_sprites.get(mouse_ev.button_index)
		if tex:
			sprite.texture = tex
			sprite.visible = true
			text = ""
		else:
			sprite.visible = false
			text = mouse_ev.as_text()


func _on_timer_timeout() -> void:
	button_pressed = false
