extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
enum direction {UP, DOWN}
var move_direction: direction = direction.DOWN
const SPEED: int = 5


func _ready() -> void:
	resetComp.resetting_stats.connect(reset)

func _physics_process(_delta: float) -> void:
	velocity.x = 0
	set_velocity(velocity)
	move_and_slide()
	
	match move_direction:
		direction.UP:
			velocity.y -= SPEED
			if is_on_ceiling():
				set_movement(2)
		direction.DOWN:
			velocity.y += SPEED * 4.5
			if is_on_floor():
				set_movement(1)


func reset() -> void:
	velocity = Vector2.ZERO
	move_direction = direction.DOWN
	timer.stop()
	timer.wait_time = 1
	set_movement(2)

func set_movement(wait_time: int) -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)
	timer.start(wait_time)
	await timer.timeout
	move_direction = direction.UP if (move_direction == direction.DOWN) else direction.DOWN
	set_physics_process(true)
