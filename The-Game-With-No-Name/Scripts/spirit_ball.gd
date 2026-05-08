extends Node2D
class_name  SpiritBall

signal died(value: SpiritBall)

var life_time: float = 0.58

var left: bool = false
var time: float = life_time

@onready var hit_box: HitBox = $Hitbox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	time -= delta
	
	var move: Vector2 = Vector2(-1 if left else 1, 0)
	global_position += move * 300 * delta
	
	if time < 0:
		died.emit(self)
