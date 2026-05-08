extends CharacterBody2D
class_name Pet

@export var stop_distance: float = 23

@onready var animatedSprite: AnimatedSprite2D = $ghost_dog

@export var playerNode: Player
var SPEED: int = 120
@export var player: int = 1

func _ready() -> void:   
	animatedSprite.play("pet_%d" % player)
	await get_tree().process_frame
	playerNode.animation.flip_changed.connect(flip)

func _physics_process(_delta: float) -> void:
	
	visible = playerNode.visible
	var direction: Vector2 = playerNode.global_position - global_position
	var distance: float = direction.length()
	
	if distance > stop_distance:
		velocity = direction.normalized() * SPEED
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.15)

	move_and_slide()

func distance_to_player() -> float:
	var direction: Vector2 = playerNode.global_position - global_position
	var distance: float = direction.length()
	return distance

func flip(value: bool) -> void:
	var tween: Tween
	tween = create_tween()
	var x_position: float = 23 if value else -23
	tween.finished.connect(Callable(self, "on_tween_finished"))
	tween.tween_property(animatedSprite, "position", Vector2(x_position, 0) , 0.2)


func on_tween_finished() -> void:
	animatedSprite.flip_h = playerNode.animated_sprite.flip_h
