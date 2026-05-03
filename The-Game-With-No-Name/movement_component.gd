extends Node
class_name MovementComponent

signal walljumped(direction: float)
signal moved_horizontal(direction: float)
signal jumped
signal knockbacked(force: Vector2)

@export_category("Nodes")
@export var water_detector: LavaWaterDetector
@export var body: CharacterBody2D

@export_category("X Velocity")
@export var SPEED: int = 120
@export var WATER_SPEED: int = 80
@export var ACCELERATION: int = 20

@export_category("Gravity")
@export var GRAVITY: int = 600
@export var WATER_GRAVITY: int = 200

@export_category("Y Velocity")
@export var JUMP_POWER: int = 210
@export var WATER_JUMP_POWER: int = 100
@export var WALL_JUMP_FORCE: float = 2.6
@export var KNOCKBACK_DAMPENING: int = 900


var knockback_velocity: Vector2 = Vector2.ZERO
var in_knockback: bool = false

func setup(p: CharacterBody2D, water: LavaWaterDetector) -> void:
	body = p
	water_detector = water

func move_horizontal(dir: float, _slowed: bool = false) -> void:
	var target_speed: float = WATER_SPEED if water_detector.inWater else SPEED
#	if slowed:
#		print("slowed")
#		target_speed *= 0.5
	
	body.velocity.x = move_toward(
		body.velocity.x,
		dir * target_speed,
		ACCELERATION
	)
	moved_horizontal.emit(dir)


func apply_gravity(delta: float) -> void:
	var g: float = WATER_GRAVITY if water_detector.inWater else GRAVITY
	body.velocity.y += g * delta


func jump() -> void:
	body.velocity.y = 0
	body.velocity.y -= (
			WATER_JUMP_POWER if water_detector.inWater else JUMP_POWER
		)
	jumped.emit()

func wall_jump(direction: float) -> void:
	# direction: -1 = rechts, +1 = links
	body.velocity.y = 0
	body.velocity =Vector2(
		direction * SPEED * WALL_JUMP_FORCE, - JUMP_POWER * 1.2
		)
	walljumped.emit(direction)

func start_knockback(force: Vector2) -> void:
	knockback_velocity = force
	in_knockback = true
	knockbacked.emit(force)

func update_knockback(delta: float) -> void:
	if not in_knockback:
		return
	
	body.velocity = knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		KNOCKBACK_DAMPENING * delta
	)

	if knockback_velocity.length() < 10.0:
		knockback_velocity = Vector2.ZERO
		in_knockback = false
