extends CharacterBody2D

const rotationSpeed: int = 5
var is_alive: bool = true

@onready var DetectPlayer: PlayerDetector = $PlayerDetector
@onready var animatedSprite: AnimatedSprite2D = $SpeerFish
@onready var wait_timer: Timer = $wait_timer
@onready var move_dur_timer: Timer = $move_dur_timer
@onready var lavaWaterDetector: LavaWaterDetector = $LavaWater_Detector
@onready var healthComp: healthComponent = $healthComponent
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent

const SPEED: int = 400
var is_moving: bool = false

func _ready() -> void:
	lavaWaterDetector.water_exited.connect(on_stomp)


func _physics_process(delta: float) -> void:
	move_and_slide()
	
	velocity = (Vector2(1, 0).rotated(self.rotation) * SPEED) if is_moving else Vector2(0, 0)
	
	if DetectPlayer.focus_player and not is_moving:
		var direction: Vector2 = (DetectPlayer.focus_player.position - position)
		var angleTo: float = transform.x.angle_to(direction)
		var value: float = sign(angleTo) * min(delta * rotationSpeed, abs(angleTo))
		rotate(value)
		if wait_timer.is_stopped():
			wait_timer.start()


func defeated() -> void:
	healthComp.health = healthComp.max_health


func on_stomp() -> void:
	if is_alive:
		is_alive = false
		animatedSprite.play("die")


func _on_SpeerFish_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()


func _on_move_duration_timeout() -> void:
	is_moving = false
	if G.playerAlive[1] and G.playerAlive[0]:
		DetectPlayer.changeTarget()



func _on_wait_time_timeout() -> void:
	is_moving = true
	move_dur_timer.start()
