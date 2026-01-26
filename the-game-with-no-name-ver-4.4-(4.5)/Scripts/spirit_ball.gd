extends Node2D
class_name  SpiritBall

var left: bool = false
var time: float = 0.58

@onready var hitBox: HitBox = $Hitbox

func _ready() -> void:
	var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
	animatedSprite.flip_h = left

func _process(delta: float) -> void:
	time -= delta
	
	var move: Vector2 = Vector2(-1 if left else 1, 0)
	global_position += move * 300 * delta
	
	if time < 0:
		queue_free()
