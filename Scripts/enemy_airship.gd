extends CharacterBody2D

@onready var DetectPlayer: PlayerDetector = $PlayerDetector
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var shootComp: ShootComponent = $Shoot
@onready var resetComp: EnemyResetComponent = $ResetComponent

const SPEED: int = 100

var is_alive: bool = true

func _ready() -> void:
	var healthComp: healthComponent = $healthComponent
	healthComp.died.connect(die)
	resetComp.resetting_stats.connect(die)
	resetComp.setting_stats.connect(respawn)


func _physics_process(_delta: float) -> void:
	if not DetectPlayer.focus_player or not is_alive:
		velocity = Vector2.ZERO
		return
		
	elif DetectPlayer.focus_player:
		if timer.is_stopped():
			timer.start(0.5)
			shootComp.shoot_bullet()
		velocity.y = (DetectPlayer.focus_player.global_position.x - global_position.x)
		if not is_on_wall():
			velocity.x = (DetectPlayer.focus_player.global_position.x + global_position.x)
		else:
			velocity.x = 0
	
	velocity = velocity.normalized() * SPEED
	set_velocity(velocity)
	move_and_slide()


func die() -> void:
	is_alive = false
	animatedSprite.play("die")


func respawn() -> void:
	is_alive = true
	animatedSprite.play("default")


func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
