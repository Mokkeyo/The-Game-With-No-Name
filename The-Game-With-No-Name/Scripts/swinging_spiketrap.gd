@tool
extends Node2D
class_name SwingTrap

@export var swing_angle: float = 0
@export var speed: float = 1

var length: int


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
	var swing_comp: SwingComponent = $swing_component
	swing_comp.swing_angle = swing_angle 
	swing_comp.speed = speed
