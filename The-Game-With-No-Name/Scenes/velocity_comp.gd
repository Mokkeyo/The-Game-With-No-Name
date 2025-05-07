extends Node
class_name VelocityComponent

enum MovementMode { GROUNDED, FLYING }

var parent: CharacterBody2D
@export var max_speed: float = 100.0
@export var acceleration: float = 600.0
@export var deceleration: float = 800.0
@export var max_fall_speed: float = 1000.0
@export var movement_mode: MovementMode = MovementMode.GROUNDED

var velocity: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO

@export var gravity_component: GravityComponent
@export var jump_component: JumpComponent

func _ready() -> void:
	parent = get_parent() as CharacterBody2D

func handle_velocity(delta: float) -> void:
	if not parent:
		return
	
	# Apply movement logic based on mode
	match movement_mode:
		MovementMode.GROUNDED:
			_handle_grounded_movement(delta)
		MovementMode.FLYING:
			_handle_flying_movement(delta)
	
	if gravity_component and not parent.is_on_floor():
		velocity = gravity_component.apply_gravity(velocity, delta)
	
	if jump_component:
		velocity = jump_component.apply_jump(velocity)

	# Final movement (combine velocity)
	parent.velocity = velocity
	parent.move_and_slide()

# Handle movement for grounded characters (with gravity)
func _handle_grounded_movement(delta: float) -> void:
	# Horizontal movement
	if input_direction.x != 0:
		velocity.x = move_toward(velocity.x, input_direction.x * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)


# Handle movement for flying characters (no gravity, no ground interactions)
func _handle_flying_movement(delta: float) -> void:
	# Full 2D directional movement (X + Y)
	if input_direction != Vector2.ZERO:
		var target: Vector2 = input_direction.normalized() * max_speed
		velocity = velocity.move_toward(target, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
