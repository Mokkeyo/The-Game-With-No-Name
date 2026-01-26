@tool
extends CharacterBody2D
var is_alive: bool = true

@export var move_speed: float =2.0
@export var move_distance: float = 50.0
var time_since_init: float = 0.0

@onready var animatedSprite: AnimatedSprite2D = $bat
@onready var healthComp: healthComponent = $healthComponent
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent

@export var move_direction: Vector2 = Vector2(0, 0)
var origin: Vector2 = Vector2(0, 0)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	healthComp.died.connect(on_stomp)
	resetComp.resetting_stats.connect(respawn)
	animatedSprite.play("default")
	
	set_variables()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		return
	
	set_variables()


func set_variables() -> void:
	var move_comp: MoverComponent = $MoverComponent
	move_comp.move_speed = move_speed
	move_comp.move_distance = move_distance
	move_comp.move_direction = move_direction


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
