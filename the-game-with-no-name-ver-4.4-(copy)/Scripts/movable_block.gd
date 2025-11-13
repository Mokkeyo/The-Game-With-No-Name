extends RigidBody2D
class_name MovableBlock

var gravity_force: float = 500.0
var max_speed: float = 1000.0
var friction: float = 0.9    


func _ready() -> void:
	gravity_scale = 1
	
func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if not linear_velocity.x == 0:
		var friction_force: float = -linear_velocity.x * friction
		apply_central_impulse(Vector2(friction_force, 0))
		
		
	if linear_velocity.y < 0:
		var friction_force: float = -linear_velocity.y * friction
		apply_central_impulse(Vector2(0, friction_force))
			
	if abs(linear_velocity.x) > max_speed:
		linear_velocity.x = sign(linear_velocity.x) * max_speed
		
	if abs(linear_velocity.y) > max_speed:
		linear_velocity.y = sign(linear_velocity.y) * max_speed
