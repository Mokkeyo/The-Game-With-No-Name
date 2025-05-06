extends CharacterBody2D

var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var b: Bullet

@onready var eye: Node2D = $Node2D
@onready var shootTimer: Timer = $shootTimer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var airshipDetector: AirshipDetector = $airshipDetector
@onready var shootComponent: ShootComponent = $Shoot

func _process(_delta: float) -> void:
	if airshipDetector.focus_player:
		var value: Vector2 = airshipDetector.focus_player.global_position
		eye.look_at(value)
		if shootTimer.is_stopped():
			shootTimer.start()


func _on_shoot_timeout() -> void:
	animationPlayer.play("Warning")


func _on_AnimationPlayer_animation_finished(_anim_name: StringName) -> void:
	shootComponent.shoot_bullet()
