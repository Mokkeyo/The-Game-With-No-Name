extends Node2D
class_name Wand

var can_swing: bool = true
@onready var marker: Marker2D = $Wand/Marker2D
@onready var sprite: Sprite2D = $Wand
@onready var timer: Timer = $Timer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	sprite.visible = false
	if G.battle_mode:
		can_swing = G.wand


func attack() -> void:
	visible = true
	can_swing = false
	timer.start()
	animationPlayer.play("swing_left" if sprite.flip_h else "swing_right")


func flip(direction: int) -> void:
	sprite.rotation = direction * 15
	sprite.flip_h = direction < 0


func _on_timer_timeout() -> void:
	can_swing = true
