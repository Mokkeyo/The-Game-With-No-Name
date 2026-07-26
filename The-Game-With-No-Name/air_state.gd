extends PlayerState
class_name AirState

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

var is_walljumping: bool = false
var buffered_jump: bool = false
var can_doublejump: bool = false

const CUT_JUMP_SPEED: float = -100.0
const JUMP_BUFFER_TIME: float = 0.15
const COYOTE_TIME: float = 0.15


func enter() -> void:
	coyote_timer.start(COYOTE_TIME)
	animation.play(animation.Anim.JUMP)
	is_walljumping = false
	can_doublejump = true


func exit() -> void:
	is_walljumping = false


func handle_input() -> void:
	var dir: Vector2 = input_direction()
	
	update_combat(dir)
	
	movement.move_horizontal_normal(
		dir.x, 
		combat.is_attacking()
	)
	
	update_flip(dir)
	
	
	if input.jump_released() and player.velocity.y < CUT_JUMP_SPEED:
		cut_jump()
	
	if not input.jump_pressed():
		return
	
	if not coyote_timer.is_stopped():
		jump()
		coyote_timer.stop()
		return
	
	var wall_dir: int = wall_direction()
	
	if wall_dir != 0:
		play_jump_sound()
		movement.wall_jump(wall_dir)
		is_walljumping = true
		can_doublejump = true
		return
	
	if can_doublejump:
		can_doublejump = false
		jump()
		return
	
	start_jump_buffer()


func cut_jump() -> void:
	player.velocity.y = CUT_JUMP_SPEED
	
	if not is_walljumping:
		return
	
	player.velocity.x = 0
	is_walljumping = false

func start_jump_buffer() -> void:
	buffered_jump = true
	jump_buffer_timer.start(JUMP_BUFFER_TIME)

func clear_jump_buffer() -> void:
	buffered_jump = false
	jump_buffer_timer.stop()


func wall_direction() -> int:
	return int(player.next_to_left_wall()) - int(player.next_to_right_wall())


func jump() -> void:
	super.jump()
	is_walljumping = false


func physics_update(delta: float) -> void:
	movement.apply_normal_gravity(delta, combat.is_attacking())
	
	if player.velocity.y > 20:
		animation.play(animation.Anim.FALL)
	
	var player_velocity: float = player.velocity.y
	
	player.move_and_slide()
	
	if is_walljumping and player.is_on_wall():
		cut_jump()
	
	if player.is_on_floor():
		if buffered_jump:
			clear_jump_buffer()
			can_doublejump = true
			jump()
			return
		
		player.state_machine.change_state(PlayerStates.ID.GROUND)
		print(player_velocity)
		if player_velocity >= 180:
			AudioManager.play_sfx(Sounds.PLAYER_IMPACT, player.global_position)
		return
	
	if player.grab_zone.rope_part:
		player.state_machine.change_state(PlayerStates.ID.ROPE)
		return
	
	if player.lava_water_detector.in_water:
		player.state_machine.change_state(PlayerStates.ID.WATER_AIR)
		AudioManager.play_sfx(Sounds.WATER_ENTER, player.global_position)

func _on_jump_buffer_timer_timeout() -> void:
	clear_jump_buffer()


func _on_hitbox_damaged_enemy() -> void:
	can_doublejump = true
	jump()
