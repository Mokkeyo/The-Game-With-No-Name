extends CharacterBody2D
class_name Pet

@export var stop_distance: float = 40

@onready var animated_sprite: AnimatedSprite2D = $ghost_dog

@export var player_node: Player
@export var speed: float = 120.0
@export var acceleration: float = 900.0
@export var player: int = 1

func _ready() -> void:   
	animated_sprite.play("pet_%d" % player)


func _physics_process(delta: float) -> void:
	visible = player_node.visible
	
	var direction: Vector2 = player_node.global_position - global_position
	var distance: float = direction.length()

	if distance > stop_distance:
		var target_velocity: Vector2 = direction.normalized() * speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	
	if velocity.x < 0:
		animated_sprite.flip_h = true 
	elif velocity.x > 0:
		animated_sprite.flip_h = false
	
	move_and_slide()
