

extends Node2D
class_name ShootComponent

enum ProjectileType {BULLET, SPIRIT_BALL , LASER, WARNING}

@export var projectileType: ProjectileType = ProjectileType.BULLET

@export var shootingPoint: Marker2D
@export var parent: Node2D
@export var rotation_point: Node2D
@export var bulletSpeed: int = 250
@export var player: int
@export var lifeTime: float = 2.0
@export var pool_size: int = 5

var spiritball_scene: PackedScene = preload("res://Scenes/spirit_ball.tscn")
var spiritball_pool: Array[SpiritBall]

var laser_scene: PackedScene = preload("res://Bosse/Galaga/Szene/laser.tscn")
var laser_pool: Array[Laser]

var warning_scene: PackedScene = preload("res://Bosse/Galaga/Szene/warning.tscn")
var warning_pool: Array[Warning]

var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
var bullet_pool: Array[Bullet] = []


func _ready() -> void:
	var reset_comp: EnemyResetComponent = $ResetComponent
	reset_comp.resetting_stats.connect(reset)
	if not rotation_point:
		rotation_point = get_parent()
	
#	match projectileType:
#		ProjectileType.BULLET:
#			initialize_bullet()
#		ProjectileType.SPIRIT_BALL:
#			initialize_spirit_ball()
#		ProjectileType.LASER:
#			initialize_laser()
#		ProjectileType.WARNING:
#			initialize_laser()
	
	# Initialize the bullet pool
	for i: int in range(pool_size):
		var bullet_instance: Bullet = bullet_scene.instantiate()
		bullet_instance.timeout.connect(_on_bullet_timeout)
		bullet_instance.visible = false
		bullet_instance.call_deferred("deactivate_hibox", true)
		bullet_instance.set_physics_process(false) # Start with the bullets in the inactive state
		bullet_pool.append(bullet_instance)
		parent.get_parent().call_deferred("add_child", bullet_instance)


func reset() -> void:
	for bullet: Bullet in bullet_pool:
		deactivate_bulet(bullet)


func get_bullet() -> Node2D:
	# Retrieve an available bullet from the pool
	for bullet: Bullet in bullet_pool:
		if bullet and not bullet.visible:  # Check if the bullet is inactive
			return bullet
	return null  # Return null if no bullets are available


func shoot_bullet() -> void:
	var b: Bullet = get_bullet()
	if b:
		b.propertys(rotation_point.rotation, player, lifeTime, bulletSpeed)
		b.global_position = shootingPoint.global_position
		b.visible = true
		b.call_deferred("deactivate_hibox", false)
		b.set_physics_process(true)
		SoundMusic.play_sound_effect("shoot")


func _on_bullet_timeout(bullet: Bullet) -> void:
	# Called when a bullet's lifetime expires
	if bullet in bullet_pool:
		deactivate_bulet(bullet)


func deactivate_bulet(bullet: Bullet) -> void:
	bullet.set_physics_process(false)
	bullet.call_deferred("deactivate_hibox", true)
	bullet.global_position = Vector2(-1000, -1000)
	bullet.visible = false
