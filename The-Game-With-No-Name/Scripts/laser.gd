extends Node2D
class_name Laser

@onready var raycast: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

@onready var collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: HitBox = $Hitbox

var segment: SegmentShape2D

var targets: Array[Player] = []

func _ready() -> void:
	segment = collision.shape.duplicate() as SegmentShape2D
	collision.shape = segment
	set_active(false)

func start_laser() -> void:
	set_active(true)

func stop_laser() -> void:
	set_active(false)

func set_active(b: bool) -> void:
	set_physics_process(b)
	hitbox.monitoring = b
	visible = b

func _physics_process(_delta: float) -> void:
	print(name,": ", global_position.x)
#	raycast.force_raycast_update()
	var end_position: float = raycast.get_collision_point().x - global_position.x + 4    
	var stretch_margin: float = end_position / sprite.texture.get_size().x
	
	sprite.scale.x = stretch_margin
	
	var end_collision: float = raycast.get_collision_point().x - sprite.global_position.x
	segment.b.x = end_collision
