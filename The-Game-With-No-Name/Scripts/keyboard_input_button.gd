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
	var event: InputEvent = InputSerializer.get_event_from_action(Save.inputs, action, device_index)
	
	if not event:
		sprite.visible = false
		text = ""
		return
	
	if event is InputEventKey:
		sprite.visible = false
		var temp_text: String = event.as_text().replace(" - Physical", "")
		text = temp_text
	elif event is InputEventMouseButton:
		var mouse_ev: InputEventMouseButton = event as InputEventMouseButton
		var tex: Texture2D = mouse_sprites.get(mouse_ev.button_index)
		if tex:
			sprite.texture = tex
			sprite.visible = true
			text = ""
		else:
			sprite.visible = false
			text = mouse_ev.as_text()
