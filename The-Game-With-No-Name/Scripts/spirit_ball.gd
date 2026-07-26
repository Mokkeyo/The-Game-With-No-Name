extends Projectile
class_name  SpiritBall

var life_time: float = 0.58
var dir: int

var time: float

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func configure(definition: ProjectileDefinition) -> void:
	var def: SpiritballDefinition = definition as SpiritballDefinition
	life_time = def.lifetime
	time = life_time
	dir = def.direction

func shoot(pos: Vector2, rot: float, _owner: Node2D) -> void:
	
	global_position = pos
	global_rotation = rot
	sprite.flip_h = dir == - 1
	visible = true
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	time -= delta
	
	global_position.x += dir * 300 * delta
	
	if time < 0:
		finished.emit(self)
