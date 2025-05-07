extends Node
class_name JumpComponent

@export var velocity_component: VelocityComponent
@export var jump_velocity: float = -210.0
@export var jump_modifier: float = 1.0

var want_to_jump: bool = false
var cut_jump: bool = false

func _ready() -> void:
	assert(velocity_component != null, "VelocityComponent must be set.")

# Called when you want to jump
func request_jump(jump_power: float) -> void:
	jump_velocity = jump_power
	want_to_jump = true

# Called when you want to cancel a jump early
func request_jump_cut() -> void:
	cut_jump = true

# Apply jump logic to velocity (from the VelocityComponent)
func apply_jump(velocity: Vector2) -> Vector2:
	if want_to_jump:
		velocity.y = jump_velocity * jump_modifier
		want_to_jump = false

	if cut_jump and velocity.y < 0:
		velocity.y *= 0.5
		cut_jump = false
	
	return velocity
