extends Node2D
class_name Projectile

var velocity: Vector2
var moveSPEED: int = 250
var dir: float

@export var timer: Timer
@export var hit_box: HitBox
@export var hurt_box: HurtBox

@export_category("Sprite")
@export var animated_sprite: AnimatedSprite2D
@export var sprite: Sprite2D

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	hit_box.damage_dealth.connect(died)


func propertys() -> void:
	pass


func disable_hitbox() -> void:
	hit_box.monitoring = false


func disable_hurtbox() -> void:
	hurt_box.monitorable = false


func died() -> void:
	emit_signal("timeout", self)


func _on_timer_timeout() -> void:
	died()
