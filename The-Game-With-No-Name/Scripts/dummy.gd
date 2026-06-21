@tool
extends StaticBody2D
class_name Dummy

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var animationPlayer: AnimationPlayer = $DamagePlayer
@onready var health_comp: HealthComponent = $healthComponent

@export var door: DoorWithObj = null


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	health_comp.died.connect(die)
	collision.disabled = bool(visible != true)


func die() -> void:
	call_deferred("disable_collision")
	if door:
		door.open()
	else:
		push_warning("No Door Connected")


func disable_collision() -> void:
	var hurtBoxCollision: CollisionShape2D = $CollisionShape2D
	hurtBoxCollision.disabled = true


func _process(_delta: float) -> void:
	if door:
		door.door_color = "Dummy"
	
	if not Engine.is_editor_hint():
		set_process(false)
		return
