extends Node2D
class_name Ping

@export var play_ping: bool = true

func _ready() -> void:
	if not play_ping:
		return
	
	var animationPlayer: AnimationPlayer = $AnimationPlayer
	animationPlayer.play("default")
