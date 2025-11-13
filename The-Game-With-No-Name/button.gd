@tool
extends Node2D
class_name DoorButton

@export var door: DoorWithObj = null

@export_enum ("Player", "Stone", "Spiritball") var required_input: String = "Player"

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	animatedSprite.animation = required_input
	reset()
	if not Engine.is_editor_hint():
		var reset_comp: EnemyResetComponent = $ResetComponent
		reset_comp.resetting_stats.connect(reset)

func is_door_open() -> bool:
	if door == null:
		push_warning("No Door Connected to Button")
		return false
	
	return door.door_open


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group(required_input):
		open_door()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group(required_input):
		open_door()

func open_door() -> void:
	animatedSprite.play(required_input)
	set_button_state(1)
	door.open()
	call_deferred("disable_colllision")


func disable_colllision() -> void:
	collision.disabled = true

func set_button_state(value: int) -> void:
	animatedSprite.animation = required_input
	animatedSprite.frame_progress = value


func reset() -> void:
	if G.save_stat.door.has(door.Door_Nr):
		disable_colllision()
		set_button_state(1)
		return
	animatedSprite.animation = required_input


func _process(_delta: float) -> void:
	if door:
		door.door_color = required_input
		if door.door_open:
			animatedSprite.play(required_input)
	
	if not Engine.is_editor_hint():
		set_button_state(0 if not is_door_open() else 1)
		set_process(false)
		return
	
	#------Editor-Code----------------------#
	animatedSprite.animation = required_input
