extends PlayerState
class_name AirState

var is_walljumping: bool = false
var dir: Vector2

func enter() -> void:
	player.animation.play(player.animation.Anim.JUMP)
	is_walljumping = false

func exit() -> void:
	is_walljumping = false
	dir = Vector2.ZERO

func handle_input() -> void:
	dir = Vector2(player.input.move_dir(), player.input.y_dir())
	
	player.combat.flip_wand(dir)
	
	player.movement.move_horizontal(
		dir.x, 
		player.combat.is_attacking()
	)
	
	if not dir.x == 0:
		player.animation.flip(dir.x < 0)
	
	if player.input.attack_pressed():
		player.combat.attack()
	
	if player.input.wand_pressed():
		player.combat.cast()
	
	if player.input.jump_released() and player.velocity.y < -100:
		cut_jump()
	
	if not player.input.jump_pressed():
		return
	
	player.animation.play(player.animation.Anim.JUMP)
	
	if player.lava_water_detector.inWater:
		jump()
		return
	
	if not player.coyote_timer.is_stopped():
		jump()
		player.coyote_timer.stop()
		return
	
	if player.next_to_wall():
		var wall_dir: int = 1 if player.next_to_left_wall() else -1
		player.movement.wall_jump(wall_dir)
		is_walljumping = true
		return
	
	if player.can_doublejump:
		player.can_doublejump = false
		jump()
		return
	
	player.buffered_jump = true
	player.jump_buffer_timer.start(0.15)


func cut_jump() -> void:
	player.velocity.y = -100
	if is_walljumping:
		player.velocity.x = 0
		is_walljumping = false

func jump() -> void:
	player.movement.jump()
	is_walljumping = false

func physics_update(delta: float) -> void:
	player.movement.apply_gravity(delta, player.combat.is_attacking())
	player.combat.change_sword_direction(dir, player.animated_sprite.rotation_degrees)
	
	if player.velocity.y > 0:
		player.animation.play(player.animation.Anim.FALL)
		is_walljumping = false
	
	player.move_and_slide()
	
	if is_walljumping and player.is_on_wall():
		cut_jump()
	
	if player.is_on_floor():
		if player.buffered_jump:
			player.buffered_jump = false
			player.movement.jump()
			return
		player.change_state("ground")
		return
	
	if player.grab_zone.rope_part:
		player.change_state("rope")
