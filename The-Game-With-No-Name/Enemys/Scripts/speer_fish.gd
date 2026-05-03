extends CharacterBody2D
class_name SpeerFish

const rotationSpeed: int = 5

enum State {DEAD, IDLE, FOKUSING, MOVING}
var state: State = State.IDLE

@onready var DetectPlayer: PlayerDetector = $PlayerDetector
@onready var animatedSprite: AnimatedSprite2D = $SpeerFish
@onready var wait_timer: Timer = $wait_timer
@onready var move_dur_timer: Timer = $move_dur_timer
@onready var lavaWaterDetector: LavaWaterDetector = $LavaWater_Detector
@onready var healthComp: HealthComponent = $HealthComponent
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent

const SPEED: int = 400

func _ready() -> void:
	lavaWaterDetector.water_exited.connect(on_stomp)
	resetComp.resetting_stats.connect(resseting)

func _physics_process(delta: float) -> void:
	
	match state:
		State.DEAD:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		
		State.MOVING:
			velocity = Vector2(1, 0).rotated(self.rotation) * SPEED
		
		State.IDLE:
			velocity = Vector2.ZERO
			
			if DetectPlayer.focus_player:
				state = State.FOKUSING
		
		State.FOKUSING:
			velocity = Vector2.ZERO
			
			if not DetectPlayer.focus_player:
				state = State.IDLE
				return
			
			rotate_to_target(DetectPlayer.focus_player, delta)
			
			if wait_timer.is_stopped():
				wait_timer.start()
				
	var previous_velocity: Vector2 = velocity
	
	move_and_slide()
	check_for_collision(previous_velocity)


func check_for_collision(vel: Vector2) -> void:
	if vel.length() < 0.01:
		return
		
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		
		if not collision:
			continue
		
		var normal: Vector2 = collision.get_normal()
		
		if vel.dot(normal) < -0.7:
			velocity = vel.bounce(normal)
			state = State.IDLE
			break


func rotate_to_target(target: Node2D, delta: float) -> void:
	var direction: Vector2 = (target.global_position - global_position)
	var angleTo: float = global_transform.x.angle_to(direction)
	var value: float = sign(angleTo) * min(delta * rotationSpeed, abs(angleTo))
	rotate(value)


func defeated() -> void:
	healthComp.health = healthComp.max_health


func on_stomp() -> void:
	if not state == State.DEAD:
		state = State.DEAD
		animatedSprite.play("die")


func _on_SpeerFish_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()

func resseting() -> void:
	state = State.IDLE
	animatedSprite.play("default")

func _on_move_duration_timeout() -> void:
	state = State.IDLE
	DetectPlayer.changeTarget()


func _on_wait_time_timeout() -> void:
	state = State.MOVING
	move_dur_timer.start()
