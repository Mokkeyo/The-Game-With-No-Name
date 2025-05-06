extends Node
class_name EnemyResetComponent

signal setting_stats
signal resetting_stats

@export_group("reset_stats")
@export var collisions: Array[CollisionShape2D]
@export var visible_nodes: Array[Node2D]
@export var hpBar: progressBar
@export var healthComp: healthComponent
@export var setStartPosition: bool = true
@export var physics_process: bool = false
@export var process: bool = false

var start_position: Vector2

func _ready() -> void:
	var parent: Node2D = get_parent()
	if setStartPosition:
		start_position = parent.global_position


func reset_stats() -> void:
	var parent: Node2D = get_parent()
	
	if setStartPosition:
		parent.global_position = start_position
	
	parent.visible = true
	
	var health: float = 0
	var max_health: float = 0
	
	if healthComp:
		healthComp.health = healthComp.max_health
		health = healthComp.health
		max_health = healthComp.max_health
	
	if hpBar:
		hpBar.visible = true
		hpBar.set_value_int(float(health/max_health * 100))
	
	if physics_process:
		parent.set_physics_process(true)
	
	if process:
		parent.set_process(true)
	
	for collision: CollisionShape2D in collisions:
		collision.disabled = false
	
	for visibles: Node2D in visible_nodes:
		visibles.visible = true
	
	emit_signal("resetting_stats")


func set_stats() -> void:
	var parent: Node2D = get_parent()
	if setStartPosition:
		parent.global_position = Vector2(-1000, -1000)
	
	parent.visible = false
	
	if hpBar:
		hpBar.visible = false
	
	if physics_process:
		parent.set_physics_process(false)
	
	if process:
		parent.set_process(false)
	
	for collision: CollisionShape2D in collisions:
		collision.disabled = true
	
	for visibles: Node2D in visible_nodes:
		visibles.visible = false
	
	emit_signal("setting_stats")
