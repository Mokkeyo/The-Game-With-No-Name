extends CharacterBody2D

@onready var detect_player: PlayerDetector = $PlayerDetector
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var shoot_comp: ShootComponent = $Shoot
@onready var reset_comp: EnemyResetComponent = $ResetComponent

const SPEED: int = 100

var is_alive: bool = true

func _ready() -> void:
	var health_comp: HealthComponent = $healthComponent
	health_comp.died.connect(die)
	reset_comp.resetting_stats.connect(die)
	reset_comp.setting_stats.connect(respawn)


func _physics_process(_delta: float) -> void:
	if not detect_player.focus_player or not is_alive:
		velocity = Vector2.ZERO
		return
		
	elif detect_player.focus_player:
		if timer.is_stopped():
			timer.start(0.5)
			shoot_comp.shoot_bullet()
		velocity.y = (detect_player.focus_player.global_position.x - global_position.x)
		if not is_on_wall():
			velocity.x = (detect_player.focus_player.global_position.x + global_position.x)
		else:
			velocity.x = 0
	
	velocity = velocity.normalized() * SPEED
	set_velocity(velocity)
	move_and_slide()


func die() -> void:
	is_alive = false
	animated_sprite.play("die")


func respawn() -> void:
	is_alive = true
	animated_sprite.play("default")


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "die":
		reset_comp.set_stats()
