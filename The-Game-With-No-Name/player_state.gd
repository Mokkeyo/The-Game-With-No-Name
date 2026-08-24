extends Node
class_name PlayerState

var player: Player

var movement: MovementComponent
var combat: PlayerCombat
var animation: PlayerAnimation
var input: PlayerInput

func enter() -> void: pass
func exit() -> void: pass
func physics_update(_delta: float) -> void: pass
func handle_input() -> void: pass

#region Helper
func jump() -> void:
	play_jump_sound()
	movement.jump()


func water_jump() -> void:
	play_jump_sound()
	movement.jump_water()


func input_direction() -> Vector2:
	return Vector2(
		input.move_dir(),
		input.y_dir()
	)

func update_ground_state() -> void:
	player.rotater_component.update_rotation()
	
	var on_moving_platform: bool = player.get_platform_velocity().length_squared() > 0.0001
	var is_flat: bool = player.get_floor_angle() == 0
	
	if not on_moving_platform and is_flat:
		player.position.y = roundi(player.position.y)
	
	player.move_and_slide()


func update_combat(dir: Vector2) -> void:
	combat.change_sword_direction(dir, animation.rotation())
	combat.flip_wand(dir)
	
	if input.attack_pressed():
		combat.attack()
	
	if input.wand_pressed():
		combat.cast()

func update_flip(dir: Vector2) -> void:
	if not dir.x == 0:
		animation.flip(dir.x < 0)

func play_jump_sound() -> void:
	animation.play(animation.Anim.JUMP)
#endregion
