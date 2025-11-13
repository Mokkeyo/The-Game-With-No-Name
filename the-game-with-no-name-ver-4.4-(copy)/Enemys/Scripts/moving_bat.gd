extends CharacterBody2D
var is_alive: bool = true

@export var move_speed: float =2.0
@export var move_distance: float = 50.0
var time_since_init: float = 0.0

@onready var animatedSprite: AnimatedSprite2D = $bat
@onready var healthComp: healthComponent = $healthComponent
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent

@export var move_direction: Vector2 = Vector2(1, 1)
var origin: Vector2 = Vector2(0, 0)

func _ready() -> void:
	time_since_init = 0.0
	origin = position
	healthComp.died.connect(on_stomp)
	resetComp.resetting_stats.connect(respawn)
	animatedSprite.play("default")


func _physics_process(delta: float) -> void:
	time_since_init = time_since_init + delta
	var position_on_curve: float = sin(time_since_init * PI * move_speed)
	var offset: Vector2 = move_distance * position_on_curve * move_direction
	position = origin + offset


func respawn() -> void:
	is_alive = true
	animatedSprite.play("default")


func on_stomp() -> void:
	if is_alive:
		animatedSprite.play("die")
		is_alive = false

func _on_bat_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
