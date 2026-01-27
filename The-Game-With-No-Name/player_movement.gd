extends Node
class_name PlayerMovement

const SPEED: int = 120
const WATER_SPEED: int = 80
const ACCELERATION: int = 20

const GRAVITY: int = 600
const WATER_GRAVITY: int = 200

const JUMP_POWER: int = 210
const WATER_JUMP_POWER: int = 100
const WALL_JUMP_FORCE: float = 2.5
const KNOCKBACK_DAMPENING: int = 900

var player: CharacterBody2D
var water_detector: LavaWaterDetector

var knockback_velocity: Vector2 = Vector2.ZERO
var in_knockback: bool = false

func setup(p: CharacterBody2D, water: LavaWaterDetector) -> void:
	player = p
	water_detector = water

func move_horizontal(dir: float, slowed: bool = false) -> void:
	var target_speed: float = WATER_SPEED if water_detector.inWater else SPEED
	if slowed:
		target_speed *= 0.5
	
	player.velocity.x = move_toward(
		player.velocity.x,
		dir * target_speed,
		ACCELERATION
	)

func apply_gravity(delta: float) -> void:
	var g: float = WATER_GRAVITY if water_detector.inWater else GRAVITY
	player.velocity.y += g * delta


func jump() -> void:
	player.velocity.y = 0
	player.velocity.y -= (
			WATER_JUMP_POWER if water_detector.inWater else JUMP_POWER
		)


func wall_jump(direction: float) -> void:
	# direction: -1 = rechts, +1 = links
	player.velocity =Vector2(
		direction * SPEED * -WALL_JUMP_FORCE, - JUMP_POWER
		)

func start_knockback(force: Vector2) -> void:
	knockback_velocity = force
	in_knockback = true


func update_knockback(delta: float) -> void:
	if not in_knockback:
		return
	
	player.velocity = knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		KNOCKBACK_DAMPENING * delta
	)

	if knockback_velocity.length() < 10.0:
		knockback_velocity = Vector2.ZERO
		in_knockback = false
