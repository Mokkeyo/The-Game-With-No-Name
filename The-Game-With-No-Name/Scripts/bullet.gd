extends Projectile
class_name Bullet

@onready var timer: Timer = $Timer

var speed: int
var lifetime: float
var bullet_type: BulletDefinition.BulletType

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	hitbox.damaged_enemy.connect(died)

func configure(definition: ProjectileDefinition) -> void:
	var data: BulletDefinition = definition as BulletDefinition
	speed = data.speed
	lifetime = data.life_time
	bullet_type = data.bullet_type
	print("BULLET TYPE: ", bullet_type)


func shoot(pos: Vector2, rot: float, _owner: Node2D) -> void:
	var sprite: Sprite2D = $Sprite
	assert(sprite)
	
	sprite.frame = bullet_type
	
	global_position = pos
	global_rotation = rot
	
	match bullet_type:
		BulletDefinition.BulletType.PLAYER_1:
			player_bullet(sprite)
		BulletDefinition.BulletType.PLAYER_2:
			player_bullet(sprite)
		BulletDefinition.BulletType.ENEMY:
			lifetime = 0.5
			hitbox.set_collision_mask_value(2, true)
			direction = Vector2.LEFT.rotated(rotation)
	
	visible = true
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
