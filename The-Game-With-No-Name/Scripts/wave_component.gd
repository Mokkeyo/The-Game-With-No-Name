extends Node2D
class_name WaveComponent

@export var wave_point: Marker2D
@export var parent: Node2D
@export var move_direction: int

var pool_size: int = 1
var wave_scene: PackedScene = preload("res://Bosse/Hades/Szene/wave_attack.tscn")
var wave_pool: Array[Wave] = []

func _ready() -> void:
	# Initialize the bullet pool
	for i: int in range(pool_size):
		var wave_instance: Wave = wave_scene.instantiate()
		wave_instance.timeout.connect(_on_wave_timeout)
		wave_instance.visible = false
		wave_instance.call_deferred("deactivate_hitbox", true)
		wave_instance.set_physics_process(false) # Start with the bullets in the inactive state
		wave_pool.append(wave_instance)
		if parent:
			parent.get_parent().call_deferred("add_child", wave_instance)


func get_wave() -> Node2D:
	# Retrieve an available bullet from the pool
	for wave: Wave in wave_pool:
		if wave and not wave.visible:  # Check if the bullet is inactive
			return wave
	return null  # Return null if no bullets are available



func shoot_wave() -> void:
	var w: Wave = get_wave()
	if w:
		w.propertys(1, move_direction, 300)
		w.global_position = wave_point.global_position
		w.visible = true
		w.call_deferred("deactivate_hitbox", false)
		w.set_physics_process(true)


func _on_wave_timeout(wave: Wave) -> void:
	# Called when a bullet's lifetime expires
	if wave in wave_pool:
		wave.set_physics_process(false)
		wave.call_deferred("deactivate_hitbox", true)
		wave.global_position = Vector2(-1000, -1000)
		wave.visible = false
