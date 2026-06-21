extends Node2D
class_name Warning

@onready var raycast: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	set_active(false)

func start_warning() -> void:
	set_active(true)


func stop_warning() -> void:
	set_active(false)


func set_active(b: bool) -> void:
	set_physics_process(b)
	visible = b


func _physics_process(_delta: float) -> void:
	print(name,": ", global_position.x)
	raycast.force_raycast_update()
	var end_position: float = raycast.get_collision_point().x - global_position.x + 4    
	var stretch_margin: float = end_position / sprite.texture.get_size().x
	
	sprite.scale.x = stretch_margin
