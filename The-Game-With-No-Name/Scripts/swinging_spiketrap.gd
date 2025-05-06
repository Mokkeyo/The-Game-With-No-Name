extends Node2D

@export var ANIMATION_SPEED: int = 1
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@export var check_animation: bool = false

func _ready() -> void:
	animationPlayer.speed_scale = ANIMATION_SPEED
	animationPlayer.play("default")
