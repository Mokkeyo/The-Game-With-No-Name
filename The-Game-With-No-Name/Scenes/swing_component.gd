@tool

extends Node2D
class_name SwingComponent

@export_enum ("Left", "Right") var swing_direction: String = "Right"
@export var length: int = 0
@export_range(0, 360) var swing_angle: float = 0

@export var speed: float
@export var rotating_object: Node2D

var swing_tween: Tween
var swing_direction_sign: float = 1

func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		swing_direction_sign = 1.0 if swing_direction == "Right" else -1.0
		_start_swing_tween()

func _start_swing_tween() -> void:
	if swing_tween:
		swing_tween.kill()
	
	swing_tween = create_tween()
	swing_tween.set_trans(Tween.TRANS_SINE)
	swing_tween.set_ease(Tween.EASE_IN_OUT)
	
	var from_angle: float = -swing_angle * swing_direction_sign
	var to_angle: float = swing_angle * swing_direction_sign
	
	swing_tween.tween_property(rotating_object, "rotation_degrees", from_angle, speed)
	
	swing_tween.tween_callback(func() ->void:
		AudioManager.play_sfx(Sounds.SWING, rotating_object.global_position)
	)
	
	swing_tween.tween_property(rotating_object, "rotation_degrees", to_angle, speed)
	swing_tween.tween_callback(func() ->void:
		AudioManager.play_sfx(Sounds.SWING, rotating_object.global_position)
	)

	swing_tween.set_loops()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	var dir : float= 1.0 if swing_direction == "Right" else -1.0
	var max_angle: float = deg_to_rad(swing_angle)
	var steps : int = 50
	var points: Array[Vector2] = []
	
	for i: int in range(steps + 1):
		var t : float= float(i) / steps
		var angle : float= lerp(-max_angle, max_angle, t) * dir
		var pos : Vector2= Vector2(sin(angle) * length, cos(angle) * length)
		points.append(pos)
	
	
	for i: int in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color(0.4, 0.9, 1.0), 1.0)
	
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		set_process(false)
