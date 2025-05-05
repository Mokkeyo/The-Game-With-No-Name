extends Node2D
class_name Sword

@export var sword_left: bool = false
@export var battle_mode: bool = false
@export var player: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitBox: HitBox = $Sprite2D/Hitbox
@onready var hitBoxCollision: CollisionShape2D = $Sprite2D/Hitbox/CollisionShape2D
@onready var visibleTimer: Timer = $VisibleTimer
@onready var attackTimer: Timer = $AttackTimer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var waitTimer: Timer = $WaitTimer

var swing_down: bool = true
var can_swing: bool = true
var can_flip: bool = true
var slow_down: bool = false
var swing_count: int = 0

func _ready() -> void:
	if G.battle_mode:
		visible = G.sword


func attack() -> void:
	visibleTimer.start()
	attackTimer.start()
	can_flip = false
	SoundMusic.play_sound_effect("sword")
	
	if swing_down:
		animationPlayer.play("SwingLeft(Down)" if sword_left else "SwingRight(Down)")
	else:
		animationPlayer.play("SwingLeft(Up)" if sword_left else "SwingRight(Up)")
	
	swing_down = not swing_down
	can_swing = false
	slow_down = true
	swing_count += 1
	waitTimer.start(1.0 if swing_count > 2 else 0.2)


func flip(direction: int) -> void:
	hitBox.knockback = 10 * direction
	sword_left = direction < 0
	sprite.rotation = direction * 40 if swing_down else direction * 140


func _on_VisibleTimer_timeout() -> void:
	sprite.visible = false


func _on_AnimationPlayer_animation_finished(_animation: String) -> void:
	slow_down = false
	can_flip = true


func _on_AttackTimer_timeout() -> void:
	swing_count = 0


func _on_wait_timer_timeout() -> void:
	can_swing = true
	if swing_count > 2:
		swing_count = 0
