extends CharacterBody2D

var is_alive: bool = true

@onready var animatedSprite: AnimatedSprite2D = $bat
@onready var detectPlayer: PlayerDetector = $PlayerDetector
@onready var hpBar: progressBar = $HPBar
@onready var healthComp: healthComponent = $healthComponent
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent

@export var hitoints: float = 20
@export var SPEED: int = 2


func _ready() -> void:
	animatedSprite.play("default")
	healthComp.health = hitoints
	healthComp.max_health = hitoints
	healthComp.died.connect(die)
	resetComp.resetting_stats.connect(respawn)


func _physics_process(_delta: float) -> void:
	if not is_alive:
		return
		
	if detectPlayer.focus_player:
		velocity = (detectPlayer.focus_player.global_position - global_position).normalized() * SPEED
		move_and_slide()


func die() -> void:
	healthComp.health = 0
	is_alive = false
	animatedSprite.play("die")


func respawn() -> void:
	is_alive = true
	animatedSprite.play("default")


func _on_bat_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
