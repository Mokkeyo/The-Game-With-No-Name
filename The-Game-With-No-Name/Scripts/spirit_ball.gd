extends Projectile
class_name SpiritBall

var life_time: float = 0.58
var dir: int
var speed: int = 300

func _ready() -> void:
	super._ready()

func configure(definition: ProjectileDefinition) -> void:
	var data: SpiritballDefinition = definition as SpiritballDefinition
	life_time = data.life_time
	dir = data.direction
	speed = data.speed


func shoot(pos: Vector2, rot: float, _owner: Node2D) -> void:
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	var timer: Timer = $Timer
	
	assert(sprite)
	assert(timer)
	
	global_position = pos
	global_rotation = rot
	sprite.flip_h = dir == - 1
	
	visible = true
	set_physics_process(true)
	timer.start(life_time)


func _physics_process(delta: float) -> void:
	global_position.x += dir * speed * delta


func _on_timer_timeout() -> void:
	finished.emit(self)
