extends PlayerState
class_name AirState

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

const CUT_JUMP_SPEED: float = -100.0
const JUMP_BUFFER_TIME: float = 0.15
const COYOTE_TIME: float = 0.15

var is_walljumping: bool = false
var buffered_jump: bool = false
var can_doublejump: bool = false


func enter() -> void:
	coyote_timer.start(COYOTE_TIME)
	
	is_walljumping = false
	buffered_jump = false
	can_doublejump = true
	
	animation.play(animation.Anim.JUMP)


func exit() -> void:
	is_walljumping = false
	buffered_jump = false
	jump_buffer_timer.stop()


func handle_input() -> void:
	var direction: Vector2 = input_direction()
	
	update_combat(direction)
	
	movement.move_horizontal_normal(
		direction.x, 
		combat.is_attacking()
	)
	
	update_flip(direction)
	
	if input.jump_released():
		cut_jump(direction)
	
	if not input.jump_pressed():
		return
	
	if can_coyote_jump():
		jump()
		coyote_timer.stop()
		return
	
	var wall_dir: int = wall_direction()
	
	if wall_dir != 0:
		wall_jump(wall_dir)
		return
	
	if can_doublejump:
		double_jump()
		return
	
	start_jump_buffer()


func can_coyote_jump() -> bool:
	return not coyote_timer.is_stopped()


func wall_jump(wall_dir: float) -> void:
	play_jump_sound()
	
	AudioManager.play_sfx(
		Sounds.PLAYER_JUMP, 
		player.global_position
	)
	
	movement.wall_jump(wall_dir)
	
	is_walljumping = true
	can_doublejump = true


func double_jump() -> void:
	AudioManager.play_sfx(
		Sounds.PLAYER_AIR_JUMP, 
		player.global_position
	)
	
	can_doublejump = false
	jump()


func jump() -> void:
	super.jump()
	is_walljumping = false


func cut_jump(direction: Vector2) -> void:
	if player.velocity.y < CUT_JUMP_SPEED:
		player.velocity.y = CUT_JUMP_SPEED
	
	if not is_walljumping:
		return
	
	if direction.x == 0.0:
		player.velocity.x = 0.0
	
	is_walljumping = false


func start_jump_buffer() -> void:
	if buffered_jump:
		return
	
	buffered_jump = true
	jump_buffer_timer.start(JUMP_BUFFER_TIME)


func clear_jump_buffer() -> void:
	buffered_jump = false
	jump_buffer_timer.stop()


func wall_direction() -> int:
	if player.next_to_right_wall():
		return -1
	
	if player.next_to_left_wall():
		return 1
	
	return 0


func physics_update(delta: float) -> void:
	movement.apply_normal_gravity(
		delta, 
		combat.is_attacking()
	)
	
	update_fall_animation()
	
	var impact_velocity: float = player.velocity.y
	
	player.move_and_slide()
	
	if is_walljumping and player.is_on_wall():
		is_walljumping = false
	
	if player.is_on_floor():
		handle_landing(impact_velocity)
		return
	
	if player.grab_zone.rope_part:
		player.state_machine.change_state(PlayerStates.ID.ROPE)
		return
	
	if player.lava_water_detector.in_water:
		enter_water()


func update_fall_animation() -> void:
	if player.velocity.y > 20.0:
		animation.play(animation.Anim.FALL)


func handle_landing(impact_velocity: float) -> void:
	if buffered_jump:
		clear_jump_buffer()
		can_doublejump = true
		jump()
		return
	
	
	player.state_machine.change_state(
		PlayerStates.ID.GROUND
	)
	
	if impact_velocity > 180.0:
		AudioManager.play_sfx(
			Sounds.PLAYER_IMPACT,
			player.global_position
		)


func enter_water() -> void:
	player.state_machine.change_state(
		PlayerStates.ID.WATER_AIR
	)
	
	AudioManager.play_sfx(
		Sounds.WATER_ENTER,
		player.global_position
	)


func _on_jump_buffer_timer_timeout() -> void:
	clear_jump_buffer()


func _on_hitbox_damaged_enemy() -> void:
	can_doublejump = true
	jump()
