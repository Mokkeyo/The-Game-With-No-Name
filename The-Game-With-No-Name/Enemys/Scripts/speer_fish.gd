extends CharacterBody2D
class_name SpeerFish

const ROTATION_SPEED: float = 5.0

enum State {DEAD, IDLE, FOKUSING, MOVING}
var state: State = State.IDLE

@onready var player_det: PlayerDetector = $PlayerDetector
@onready var animated_sprite: AnimatedSprite2D = $SpeerFish
@onready var wait_timer: Timer = $wait_timer
@onready var move_dur_timer: Timer = $move_dur_timer
@onready var water_det: LavaWaterDetector = $LavaWater_Detector
@onready var health_comp: HealthComponent = $HealthComponent
@onready var reset_comp: EnemyResetComponent = $EnemyResetComponent

const SPEED: float = 400.0

func _ready() -> void:
	water_det.water_entered.connect(on_stomp)
	reset_comp.enabling_stats.connect(resetting)


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	match state:
		State.DEAD:
			return
		
		State.MOVING:
			velocity = transform.x * SPEED
		
		State.IDLE:
			if player_det.focus_player:
				state = State.FOKUSING
				wait_timer.start()
		
		State.FOKUSING:
			if not player_det.focus_player:
				state = State.IDLE
				wait_timer.stop()
				return
			
			rotate_to_target(player_det.focus_player, delta)
			
	var previous_velocity: Vector2 = velocity
	
	check_for_collision(previous_velocity)
	move_and_slide()


func check_for_collision(vel: Vector2) -> void:
	if vel.length_squared() < 0.0001:
		return
		
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		
		if not collision:
			continue
		
		velocity = Vector2.ZERO


func rotate_to_target(target: Node2D, delta: float) -> void:
	var direction: Vector2 = (target.global_position - global_position).normalized()
	var angle_to_target: float = global_transform.x.angle_to(direction)
	var rotation_step: float = sign(angle_to_target) * min(delta * ROTATION_SPEED, abs(angle_to_target))
	rotate(rotation_step)


func on_stomp(entered: bool) -> void:
	await get_tree().physics_frame
	if not state == State.DEAD and entered == false:
		
		if water_det.in_water:
			return
		
		state = State.DEAD
		animated_sprite.play("die")


func _on_SpeerFish_animation_finished() -> void:
	if animated_sprite.animation == "die":
		reset_comp.disable_stats()

func resetting() -> void:
	state = State.IDLE
	
	velocity = Vector2.ZERO
	rotation = 0
	
	water_det.in_water = true
	player_det.focus_player = null
	
	wait_timer.stop()
	move_dur_timer.stop()
	animated_sprite.play("default")
	print("resseting")

func _on_move_duration_timeout() -> void:
	state = State.IDLE
	player_det.changeTarget()


func _on_wait_time_timeout() -> void:
	state = State.MOVING
	move_dur_timer.start()
