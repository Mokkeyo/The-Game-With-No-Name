extends Node2D
class_name PathFollowComponent

@export var path: Path2D
@export var target_node: Node2D
@export var speed: float = 50
@export var loop: bool = true
@export var rotate_target: bool = false
@export var show_path: bool = false

var path_color: Color = Color(0.4, 0.9, 1.0)
var path_thickness: float = 0.5

var path_follow: PathFollow2D
var is_closed: bool = false
var direction: int = 1

func _ready() -> void:
	if path == null:
		push_warning("PathfollowComponent: Path not set")
		return
	
	if target_node == null:
		target_node = get_parent()
	
	path_follow = PathFollow2D.new()
	path.add_child.call_deferred(path_follow)
	path_follow.loop = loop
	
	is_closed = _is_curve_closed(path.curve)
	
	queue_redraw()


func _physics_process(delta: float) -> void:
	if path_follow == null:
		return
	
	path_follow.progress += speed * delta * direction
	
	if not is_closed:
		if path_follow.progress_ratio >= 1:
			path_follow.progress_ratio = 1
			direction = -1
		elif path_follow.progress_ratio <= 0:
			path_follow.progress_ratio = 0
			direction = 1
	
	target_node.global_position = path_follow.global_position
	
	if rotate_target:
		target_node.rotation = path_follow.rotation
	
	if not loop and path_follow.progress_ratio >= 1.0:
		path_follow.progress_ratio = 1.0


func _is_curve_closed(curve: Curve2D) -> bool:
	if curve == null or curve.point_count < 2:
		return false
	
	var first_point: Vector2 = curve.get_point_position(0)
	var last_point: Vector2 = curve.get_point_position(curve.point_count - 1)
	
	return first_point.distance_to(last_point) == 0

func _draw() -> void:
	if path == null or path.curve == null or not show_path:
		return
	
	var curve: Curve2D = path.curve
	var points: Array[Vector2] = []
	
	for i: int in range(curve.point_count):
		points.append(curve.get_point_position(i))
	
	for i: int in range(points.size() - 1):
		draw_line(points[i], points[i + 1], path_color, path_thickness)
