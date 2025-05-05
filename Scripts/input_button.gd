extends Button 
class_name KInputButton

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@export var action: String = "ui_up"
@export var controlls_menu: Controlls

func _init() -> void:
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready() -> void:
	set_process_input(false)
	if FileAccess.file_exists(G.save_path + G.save_file_name[5]):
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
	
	if event.is_pressed() and (event is InputEventMouseButton or event is InputEventKey):
		remap_key(event)
		G.SavedInputMap.inputMap[action] = event
		G.save_inputs()
		timer.start()


func remap_key(event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	display_key()


func display_key() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		sprite.visible = false
		text = ""
		return
	
	var input_name:String = events[0].as_text()
	
	if events[0] is InputEventKey:
		sprite.visible = false
		text = input_name
	else:
		sprite.texture = load("res://Button/%s.png" % input_name)
		sprite.visible = true
		text = ""


func _on_timer_timeout() -> void:
	button_pressed = false
