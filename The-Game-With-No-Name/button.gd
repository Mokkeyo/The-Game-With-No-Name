@tool
extends Node2D
class_name DoorButton

@export var door: DoorWithObj = null

@export_enum ("Player", "Stone", "Spiritball") var required_input: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

var number_of_inputs: int = 4

func required_input_string() -> String:
	match required_input:
		0: return "Player"
		1: return "Stone"
		2: return "Spiritball"
		_: return ""


func _ready() -> void:
	sprite.frame = int(required_input)
	reset()
	if not Engine.is_editor_hint():
		var reset_comp: EnemyResetComponent = $ResetComponent
		reset_comp.resetting_stats.connect(reset)


func is_door_open() -> bool:
	if not door:
		push_warning("No Door Connected to Button")
		return false
	
	return door.door_open


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group(required_input_string()):
		open_door()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group(required_input_string()):
		open_door()


func open_door() -> void:
	sprite.frame = int(required_input + number_of_inputs)
	if door:
		door.open()
	call_deferred("disable_collision")


func disable_collision() -> void:
	collision.disabled = true


func reset() -> void:
	if not door:
		return
	
	var door_open: bool = Save.player.door.has(door.Door_Nr)
	if door_open:
		disable_collision()
	
	sprite.frame = int(required_input + number_of_inputs if door_open else required_input)


func _process(_delta: float) -> void:
	if door:
		door.door_color = required_input_string()
		if door.door_open:
			sprite.frame = int(required_input + number_of_inputs)
	
	if not Engine.is_editor_hint():
		set_process(false)
		return
	
	#------Editor-Code----------------------#
	sprite.frame = int(required_input)
