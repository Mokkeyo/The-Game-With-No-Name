extends Node
class_name VelocityComp

enum MovementMode { GROUNDED, FLYING }

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
	# Ensure components are available
	assert(gravity_component != null, "GravityComponent is required.")
	assert(jump_component != null, "JumpComponent is required.")

func _physics_process(delta: float) -> void:
	var parent :CharacterBody2D = get_parent() as CharacterBody2D
	if not parent:
		return
	
	# Gather input directions (horizontal or target follow)
#	input_direction = _get_combined_direction()

	# Apply movement logic based on mode
	match movement_mode:
		MovementMode.GROUNDED:
			_handle_grounded_movement(delta)
		MovementMode.FLYING:
			_handle_flying_movement(delta)

	# Apply gravity
	velocity = gravity_component.apply_gravity(velocity, delta)

	# Handle jump logic
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

	# Apply falling velocity (if grounded)
	if velocity.y > 0:
		velocity.y = min(velocity.y, max_fall_speed)

# Handle movement for flying characters (no gravity, no ground interactions)
func _handle_flying_movement(delta: float) -> void:
	# Full 2D directional movement (X + Y)
	if input_direction != Vector2.ZERO:
		var target: Vector2 = input_direction.normalized() * max_speed
		velocity = velocity.move_toward(target, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
