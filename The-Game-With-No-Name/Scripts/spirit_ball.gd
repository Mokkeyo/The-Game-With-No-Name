extends Projectile
class_name SpiritBall

@export var life_time: float = 0.58
var dir: int
@export var speed: int = 300

func _ready() -> void:
	super._ready()


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
