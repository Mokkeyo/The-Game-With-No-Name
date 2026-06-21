extends Node2D
class_name Warning

@onready var raycast: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	set_active(false)

func start_warning(p: Vector2, r: float) -> void:
	rotation_degrees = r
	global_position = p
	set_active(true)


func stop_warning() -> void:
	set_active(false)


func set_active(b: bool) -> void:
	set_physics_process(b)
	visible = b


func _physics_process(_delta: float) -> void:
	
	print(name, global_position)
	
	raycast.force_raycast_update()

	var length: float

	if raycast.is_colliding():
		length = raycast.global_position.distance_to(raycast.get_collision_point())
	else:
		length = raycast.target_position.length()

	sprite.scale.x = length / sprite.texture.get_size().x
