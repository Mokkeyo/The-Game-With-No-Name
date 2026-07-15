extends Node
class_name MovementComponent

signal walljumped(direction: float)
signal moved_horizontal(direction: float)
signal jumped

const SLOWED_SPEED_FACTOR: float = 0.05
const WALL_JUMP_HEIGHT_MULTIPLIER: float = 1.2

@export_category("X Velocity")
@export var speed: float = 120
@export var water_speed: float = 80
@export var acceleration: float = 20

@export_category("Gravity")
@export var gravity: float = 600
@export var water_gravity: float = 200

@export_category("Y Velocity")
@export var jump_power: float = 210
@export var water_jump_power: float = 100
@export var wall_jump_force: float = 2.6

var body: CharacterBody2D

func setup(p: CharacterBody2D) -> void:
	assert(p != null)
	body = p

#region movement
func move_horizontal_normal(dir: float, slowed: bool = false) -> void:
	_move_horizontal(speed, dir, slowed)


func move_horizontal_water(dir: float, slowed: bool = false) -> void:
	_move_horizontal(water_speed, dir, slowed)


func _move_horizontal(speed_value: float, dir: float, slowed: bool = false) -> void:
	if slowed:
		speed_value *= SLOWED_SPEED_FACTOR
	
	body.velocity.x = move_toward(
		body.velocity.x,
		dir * speed_value,
		acceleration
	)
	moved_horizontal.emit(dir)
#endregion

#region gravity
func apply_normal_gravity(delta: float, slowed: bool = false) -> void:
	_apply_gravity(gravity, delta, slowed)


func apply_water_gravity(delta: float, slowed: bool = false) -> void:
	_apply_gravity(water_gravity, delta, slowed)


func _apply_gravity(gravity_value: float, delta: float, slowed: bool = false) -> void:
	if slowed and body.velocity.y > 0:
		# Limit falling speed while attacking.
		body.velocity.y = 0
	
	body.velocity.y += gravity_value * delta
#endregion

#region jump
func jump() -> void:
	_apply_jump(jump_power)


func jump_water() -> void:
	_apply_jump(water_jump_power)

func _apply_jump(jump_value: float) -> void:
	body.velocity.y = -jump_value
	jumped.emit()

func wall_jump(direction: float) -> void:
	body.velocity = Vector2(
		direction * speed * wall_jump_force, - 
		jump_power * WALL_JUMP_HEIGHT_MULTIPLIER
	)
	
	walljumped.emit(direction)
#endregion
