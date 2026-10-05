extends Projectile
class_name Bullet

@onready var timer: Timer = $Timer

@export var speed: int
@export var lifetime: float
enum BulletType {ENEMY, PLAYER_1, PLAYER_2}

@export var bullet_type: BulletType


var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	hitbox.damaged_enemy.connect(died)


func shoot(pos: Vector2, rot: float, _owner: Node2D) -> void:
	var sprite: Sprite2D = $Sprite
	assert(sprite)
	
	sprite.frame = bullet_type
	
	global_position = pos
	global_rotation = rot
	
	match bullet_type:
		BulletType.PLAYER_1:
			player_bullet(sprite)
		BulletType.PLAYER_2:
			player_bullet(sprite)
		BulletType.ENEMY:
			hitbox.set_collision_mask_value(2, true)
			direction = Vector2.LEFT.rotated(rotation)
	
	show()
	set_physics_process(true)
	timer.start(lifetime)


func player_bullet(sprite: Sprite2D) -> void:
	sprite.flip_h = true
	hitbox.set_collision_mask_value(3, true)
	direction = Vector2.RIGHT.rotated(rotation)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func deactivate_hibox(boolean: bool) -> void:
	var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
	hitbox_collision.disabled = boolean


func died() -> void:
	finished.emit(self)


func _on_timer_timeout() -> void:
	died()
