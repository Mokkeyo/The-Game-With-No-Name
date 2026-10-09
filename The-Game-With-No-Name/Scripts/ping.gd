extends Node2D
class_name Ping

@export var play_ping: bool = true
@onready var sprite: TextureRect = %Ping
@onready var label: Label = %Label

static var texture_cache: Dictionary = {}

var pattern: RegEx = RegEx.new()
var input_device: String = "Playstation"
var device_id: int = 0

var active_players: Dictionary[int, bool] = {
	0: false,
	1: false,
}

var mouse_sprites: Dictionary = {
	MouseButton.MOUSE_BUTTON_LEFT: preload("res://Button/Left Mouse Button.png"),
	MouseButton.MOUSE_BUTTON_RIGHT: preload("res://Button/Right Mouse Button.png"),
	MouseButton.MOUSE_BUTTON_MIDDLE: preload("res://Button/Middle Mouse Button.png")
} 

func _ready() -> void:
	deactivate()

	if not play_ping:
		return
	
	Input.joy_connection_changed.connect(_on_connection_changed)
	
	var animationPlayer: AnimationPlayer = $AnimationPlayer
	animationPlayer.play("default")


func _on_connection_changed(device: int, connected: bool) -> void:
	for player: int in active_players:
		if not player:
			continue

		if not device == InputSerializer.get_device_from_player(Save.inputs, player):
			continue
		
		var device_type: int = 1 if connected else 0
		var action: String = "player%d_interact" % int(player + 1)

		print(action)

		var event: InputEvent = InputSerializer.get_event_from_action(
			Save.inputs, action, device_type
		)

		set_key_from_event(event, player)		


func display_key(player: int, value: bool = true) -> void:
	if not active_players.has(player):
		return

	active_players[player] = value

	if not value:
		if not active_players.values().has(true):
			deactivate()
		return
	
	if not play_ping:
		return
	
	show()
	set_process_unhandled_input(true)

	var player_device: int = InputSerializer.get_device_from_player(
		Save.inputs, player
	)

	var device_type: int = 0

	if Input.get_connected_joypads().has(player_device):
		device_type = 1

	var action: String = "player%d_interact" % int(player + 1)
	var event: InputEvent = InputSerializer.get_event_from_action(
		Save.inputs, action, device_type
	)
	print(action)

	set_key_from_event(event, player)


func set_key_from_event(event: InputEvent, _player: int) -> void:
	if event == null:
		sprite.hide()
		label.text = "?"
		return

	if event is InputEventKey:
		sprite.hide()
		label.text = event.as_text().replace(" - Physical", "")
		return

	if event is InputEventMouseButton:
		var mouse_ev: InputEventMouseButton = event as InputEventMouseButton
		var tex: Texture2D = mouse_sprites.get(mouse_ev.button_index)
		if tex:
			sprite.texture = tex
			sprite.show()
			label.text = ""
		else:
			sprite.hide()
			label.text = mouse_ev.as_text()
		
		return

	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var input_name: String = event.as_text()
		var result: RegExMatch = pattern.search(input_name)
		var number: int = -1
		
		if result:
			number = result.get_string().to_int()

		var special_button: bool = input_name.begins_with("Joypad Button") and (number < 4 or (number > 8 and number < 11))
		var special_motion: bool = input_name.begins_with("Joypad Motion") and (number > 3)
		
		var texture_path: String = ""

		if special_button or special_motion:
			texture_path = "res://Button/%s/%s.png" % [input_device, input_name]
		else:
			texture_path = "res://Button/%s.png" % [input_name]
		
		var texture: Texture2D = get_tex(texture_path)

		if texture:
			sprite.texture = texture
			sprite.show()
			label.text = ""
		else:
			sprite.hide()
			label.text = input_name

		return

	sprite.hide()
	label.text = event.as_text()


func get_tex(path: String) -> Texture2D:
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	
	return texture_cache[path]


func deactivate() -> void:
	hide()
	set_process_unhandled_input(false)