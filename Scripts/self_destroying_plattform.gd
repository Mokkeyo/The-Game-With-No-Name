extends Node2D

var vanished: bool = false
var stay: bool = true

@onready var staticBody: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite: Sprite2D = $falling_plattform
@onready var vanishedSprite: Sprite2D = $"falling_plattform(vanished)"
@onready var area: Area2D = $Area2D
@onready var timer: Timer = $Timer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var repearTimer: Timer = $RepearTimer


func _on_Area2D_body_entered(body: Player) -> void:
	if stay:
		if body.is_on_floor() or body.buffered_jump:
			stay = false
			timer.start()
			animationPlayer.play("Warning")

func _on_Timer_timeout() -> void:
	staticBody.disabled = true
	sprite.visible = false
	vanishedSprite.visible = true
	repearTimer.start()

func _on_RepearTimer_timeout() -> void:
	staticBody.disabled = false
	sprite.visible = true
	vanishedSprite.visible = false
	stay = true
