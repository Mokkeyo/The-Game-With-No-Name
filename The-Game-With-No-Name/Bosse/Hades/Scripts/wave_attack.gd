extends Node2D
class_name Wave

signal timeout

var time: float = 1.0
var direction: int
var speed: int = 300

func _physics_process(delta: float) -> void:
	var move: Vector2 = Vector2(direction, 0)
	global_position += move * speed * delta


func propertys(lifeTime: float, move_direction: int, move_speed: int) -> void:
	var timer: Timer = $Timer
	direction = move_direction
	speed = move_speed
	timer.start(lifeTime)


func deactivate_hitbox(boolean: bool) -> void:
	var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
	hitbox_collision.disabled = boolean


func _on_timer_timeout() -> void:
	emit_signal("timeout", self)
