extends InputButton 
class_name KInputButton

const KEYBOARD: int = 0

var mouse_sprites: Dictionary = {
	MouseButton.MOUSE_BUTTON_LEFT: preload("res://Button/Left Mouse Button.png"),
	MouseButton.MOUSE_BUTTON_RIGHT: preload("res://Button/Right Mouse Button.png"),
	MouseButton.MOUSE_BUTTON_MIDDLE: preload("res://Button/Middle Mouse Button.png")
} 


func _ready() -> void:
	device_index = KEYBOARD
	set_process_input(false)
	super._ready()
 

func _toggled(toggled_on: bool) -> void:
	super._toggled(toggled_on)
	set_process_input(toggled_on)


func _input(event: InputEvent) -> void:
	process_event(event)


func handle_input(event: InputEvent) -> InputEvent:
	if (event is InputEventMouseButton or event is InputEventKey) and event.is_pressed():
		return event
	return null


func display_key() -> void:
	var events: Array[InputEvent] = get_key()
	var ev: InputEvent = events[device_index]
	
	if not ev:
		sprite.visible = false
		text = ""
		return
	
	if ev is InputEventKey:
		sprite.visible = false
		text = ev.as_text()
	elif ev is InputEventMouseButton:
		var mouse_ev: InputEventMouseButton = ev as InputEventMouseButton
		var tex: Texture2D = mouse_sprites.get(mouse_ev.button_index)
		if tex:
			sprite.texture = tex
			sprite.visible = true
			text = ""
		else:
			sprite.visible = false
			text = mouse_ev.as_text()
