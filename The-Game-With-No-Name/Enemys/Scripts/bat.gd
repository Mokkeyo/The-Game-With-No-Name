extends CharacterBody2D
class_name Bat

var start_position: Vector2

@onready var animatedSprite: AnimatedSprite2D = $bat
@onready var detectPlayer: PlayerDetector = $PlayerDetector
@onready var healthComp: HealthComponent = $HealthComponent
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
@onready var timer: Timer = $Timer
@onready var ray: RayCast2D = $RayCast2D
@onready var nav: NavigationComponent = $NavigationComponent

enum State {DEAD, IDLE, CHASE, RETURN}
var state: State = State.IDLE

@export var hitoints: float = 20
@export var SPEED: int = 1000



func _ready() -> void:
	nav.speed = SPEED
	start_position = global_position
	animatedSprite.play("default")
	healthComp.health = hitoints
	healthComp.max_health = hitoints
	healthComp.died.connect(die)
	resetComp.resetting_stats.connect(respawn)


func _physics_process(_delta: float) -> void:
	match state:
		State.DEAD:
			return
		
		State.IDLE:
			velocity = Vector2.ZERO
			if detectPlayer.focus_player:
				state = State.CHASE
		
		State.CHASE:
			if not detectPlayer.focus_player:
				timer.stop()
				state = State.RETURN
				return
			
			nav.move_to(detectPlayer.focus_player.global_position)
		
		State.RETURN:
			if detectPlayer.focus_player:
				state = State.CHASE
			
			if global_position.distance_to(start_position) < 1:
				print("returned to start")
				timer.stop()
				state = State.IDLE
				return
			
			nav.move_to(start_position)

	move_and_slide()


func move_to_point(point: Vector2) -> void:
	velocity = (point - global_position).normalized() * SPEED




func die() -> void:
	healthComp.health = 0
	velocity = Vector2.ZERO
	state = State.DEAD
	animatedSprite.play("die")


func respawn() -> void:
	state = State.IDLE
	animatedSprite.play("default")


func _on_bat_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
