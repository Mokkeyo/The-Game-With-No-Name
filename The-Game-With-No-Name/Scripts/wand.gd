extends Node2D
class_name Wand

var can_swing: bool = true
@onready var marker: Marker2D = $Marker2D
@onready var sprite: Sprite2D = $Wand
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	sprite.visible = false


func attack() -> void:
	can_swing = false
	animationPlayer.play("swing_left" if sprite.flip_h else "swing_right")


func flip(value: bool) -> void:
	if can_swing:
		sprite.rotation_degrees = -15 if value else 15
		sprite.flip_h = value
		marker.position.x = -17 if value else 17



func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	can_swing = true
