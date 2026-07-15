extends Node2D
class_name Laser

@onready var raycast: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

@onready var collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: HitBox = $Hitbox

var segment: RectangleShape2D

var targets: Array[Player] = []

func _ready() -> void:
	segment = collision.shape.duplicate() as RectangleShape2D
	collision.shape = segment
	set_active(false)

func start_laser(p: Vector2, r: float) -> void:
	rotation_degrees = r
	global_position = p
	set_active(true)

func stop_laser() -> void:
	set_active(false)

func set_active(b: bool) -> void:
	set_physics_process(b)
	hitbox.monitoring = b
	visible = b

func _physics_process(_delta: float) -> void:
	raycast.force_raycast_update()

	var length: float

	if raycast.is_colliding():
		length = raycast.global_position.distance_to(raycast.get_collision_point())
	else:
		length = raycast.target_position.length()

	sprite.scale.x = length / sprite.texture.get_size().x
	
	segment.size.x = length
	collision.position.x = length * 0.5
	
