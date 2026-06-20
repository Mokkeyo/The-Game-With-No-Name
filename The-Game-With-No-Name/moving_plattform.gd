@tool
extends AnimatableBody2D
class_name MovingPlattform

@export var move_speed: float = 0.5
@export var move_distance: float = 50.0
@export var move_direction: Vector2 = Vector2(0, 0)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_variables()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		return
	
	set_variables()


func set_variables() -> void:
	var move_comp: MoverComponent = $MoverComponent
	move_comp.move_speed = move_speed
	move_comp.move_distance = move_distance
	move_comp.move_direction = move_direction
