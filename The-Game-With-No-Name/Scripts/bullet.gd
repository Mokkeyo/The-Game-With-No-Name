extends Node2D
class_name Bullet

signal timeout

var velocity: Vector2
var moveSPEED: int = 250
var dir: float
@onready var timer: Timer = $Timer


func _ready() -> void:
	var hitbox: HitBox = $Hitbox
	hitbox.damaged_enemy.connect(died)


func _physics_process(delta: float) -> void:
	velocity = Vector2( moveSPEED, 0).rotated(dir)
	global_position += velocity * delta

func deactivate_hibox(boolean: bool) -> void:
	var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
	hitbox_collision.disabled = boolean


func propertys(bulletRotation: float, player: int, time: float, SPEED: int) -> void:
	var sprite: Sprite2D = $bullet
	var hitbox: HitBox = $Hitbox
	moveSPEED = SPEED
	global_rotation = bulletRotation
	dir = bulletRotation
	
	sprite.frame = player
	
	var life_time: float = 1
	
	sprite.flip_h = player == 0
	hitbox.set_collision_mask_value(1, true)
	if player == 0:
		sprite.flip_h = true
		hitbox.set_collision_mask_value(2, true)
	else:
		moveSPEED = SPEED * 2
		life_time = 0.5
		hitbox.set_collision_mask_value(3, true)
	timer.stop()
	timer.wait_time = time
	timer.start(life_time)


func died() -> void:
	timeout.emit(self)


func _on_timer_timeout() -> void:
	died()
