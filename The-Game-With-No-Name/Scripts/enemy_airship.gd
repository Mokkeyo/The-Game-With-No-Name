extends CharacterBody2D
class_name EnemyAirship

@onready var detect_player: PlayerDetector = $PlayerDetector
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var shoot_comp: ShootComponent = $Shoot
@onready var reset_comp: EnemyResetComponent = $ResetComponent

const KEEP_DISTANCE: float = 200.0
const Y_TOLERANCE:float = 8.0
const SPEED: int = 140

var is_alive: bool = true

func _ready() -> void:
	var health_comp: HealthComponent = $healthComponent
	health_comp.died.connect(die)
	reset_comp.disabling_stats.connect(die)
	reset_comp.enabling_stats.connect(respawn)


func _physics_process(_delta: float) -> void:
	if not is_alive or not detect_player.focus_player:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var player: Node2D = detect_player.focus_player
	
	if timer.is_stopped():
		timer.start(0.5)
		shoot_comp.shoot()
	
	var delta_y: float = player.global_position.y - global_position.y
	
	if abs(delta_y) > Y_TOLERANCE:
		velocity.y = sign(delta_y)
	else:
		velocity.y = 0
	# Nur fliehen, wenn der Spieler zu nah ist
	var distance: float = global_position.distance_to(player.global_position)

	if distance < KEEP_DISTANCE:
		velocity.x = -sign(player.global_position.x - global_position.x)
	else:
		velocity.x = 0

	velocity = velocity.normalized() * SPEED
	move_and_slide()

func die() -> void:
	is_alive = false
	animated_sprite.play("die")


func respawn() -> void:
	is_alive = true
	animated_sprite.play("default")


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "die":
		reset_comp.disable_stats()
