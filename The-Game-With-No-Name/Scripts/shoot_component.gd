extends Node2D
class_name ShootComponent

@export var parent: Node2D
@export var shooting_point: Marker2D
@export var rotation_point: Node2D

@export var pool_size: int = 10

@export var projectile: Projectile

var pool: Array[Projectile]


func _ready() -> void:
	await get_tree().process_frame

	if projectile == null:
		push_error("ShootComponent: Kein projectile gesetzt von: ", get_parent().name)
		return

	projectile.visible = false

	for i: int in pool_size:
		var p: Projectile = projectile.duplicate() as Projectile

		if p == null:
			push_warning("ShootComponent: Konnte Projectile nicht Klonen")
			continue
		
		p.finished.connect(_on_projectile_finished)
		p.visible = false
		p.set_physics_process(false)

		if G.level_viewport:
			G.level_viewport.add_child(p)
		else:
			add_child(p)

		pool.append(p)

	if pool[0] is Bullet:
		var b: Bullet = pool[0] as Bullet
		print(b.lifetime, " ", get_parent().name)

	projectile.queue_free()
	projectile = null

func shoot(p: Projectile = null) -> void:
	
	if not p:
		p = get_projectile()

	if p == null:
		push_warning("no bullet in pool")
		return
	
	p.hitbox.monitoring = true

	p.shoot(
		shooting_point.global_position,
		rotation_point.global_rotation,
		self
	)

	p.set_physics_process(true)


func get_projectile() -> Projectile:
	for p: Projectile in pool:
		if not p.visible:
			return p
	
	push_warning("ShootComponent: No porjectile found")
	return null

func _on_projectile_finished(proj: Projectile) -> void:
	proj.deactivate()
