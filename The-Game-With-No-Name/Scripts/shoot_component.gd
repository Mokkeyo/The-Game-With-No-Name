extends Node2D
class_name ShootComponent

@export var parent: Node2D
@export var shooting_point: Marker2D
@export var rotation_point: Node2D

@export var projectile: ProjectileDefinition

var pool: Array[Projectile]

func _ready() -> void:
	await get_tree().process_frame
	
	for i: int in projectile.pool_size:
		var p: Projectile = projectile.scene.instantiate()
		
		p.finished.connect(_on_projectile_finished)
		p.hitbox.monitoring = false
		p.visible = false
		p.set_physics_process(false)
		
		G.level_viewport.add_child(p)
		
		pool.append(p)


func shoot() -> void:
	var p: Projectile = get_projectile()
	
	if p == null:
		push_warning("no bullet in pool")
		return
	
	p.configure(projectile)
	
	p.shoot(
		shooting_point.global_position,
		rotation_point.global_rotation,
		self
	)


func get_projectile() -> Projectile:
	for p: Projectile in pool:
		if p.visible == false:
			return p
	
	return null

func _on_projectile_finished(proj: Projectile) -> void:
	proj.deactivate()
