@tool
extends Node2D
class_name MoverComponent

@export var move_speed: float = 2.0
@export var move_distance: float = 50.0
@export var move_direction: Vector2 = Vector2(0, 0)

@export_category("")
@export var do_process: bool = false
@export var character_object: CharacterBody2D
@export var static_object: AnimatableBody2D

var origin: Vector2 = Vector2(0,0)
var time_since_init: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if character_object:
		origin = character_object.position
	if static_object:
		origin = static_object.position
	
	set_physics_process(do_process)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if character_object:
			static_object = null
		if static_object:
			character_object = null
		return
	
	move_body(delta)

func move_body(delta: float) -> void:
	time_since_init += delta
	var curve_pos: float = sin(time_since_init * PI * move_speed)
	var current_offset: Vector2 = move_direction * curve_pos * move_distance
	if character_object:
		character_object.velocity = (origin + current_offset - character_object.position) / delta
		character_object.move_and_slide()
	if static_object:
		static_object.global_position = origin + current_offset
		static_object.set("last_position", static_object.global_position)


#----Editor-Sript----#
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		set_process(false)

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	var start_point: Vector2 = -move_direction * move_distance
	var end_point: Vector2 = move_direction * move_distance
	
	draw_line(start_point, end_point, Color(0.2,  0.8, 1.0), 1.0)
