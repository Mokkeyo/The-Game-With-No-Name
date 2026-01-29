extends PlayerState
class_name AirState

func enter() -> void:
	player.animation.play(player.animation.Anim.JUMP)

func handle_input() -> void:
	var dir: int = player.input.move_dir()
	player.movement.move_horizontal(
		dir, 
		not player.combat.can_attack()
		)
	if not dir == 0:
		player.animation.flip(dir < 0)
	
	if player.input.attack_pressed() and player.combat.can_attack():
		player.combat.attack(dir)
	
	if player.input.wand_pressed() and player.combat.can_cast():
		player.combat.cast(dir)
	
	if player.input.jump_released() and player.velocity.y < -100:
		player.velocity.y = -100
	
	if not player.input.jump_pressed():
		return
	
	player.animation.play(player.animation.Anim.JUMP)
	
	if player.lava_water_detector.inWater:
		player.movement.jump()
		return
	
	if not player.coyote_timer.is_stopped():
		player.movement.jump()
		player.coyote_timer.stop()
		return
	
	if player.next_to_wall():
		var wall_dir: int = 1 if player.next_to_left_wall() else -1
		player.movement.wall_jump(wall_dir)
		return
	
	if player.can_doublejump:
		player.can_doublejump = false
		player.movement.jump()
		return
	
	player.buffered_jump = true
	player.jump_buffer_timer.start(0.15)


func physics_update(delta: float) -> void:
	player.movement.apply_gravity(delta)
	
	if player.velocity.y > 0:
		player.animation.play(player.animation.Anim.FALL)
	
	player.move_and_slide()
	
	if player.is_on_floor():
		if player.buffered_jump:
			player.buffered_jump = false
			player.movement.jump()
			return
		player.change_state("ground")
		return
	
	if player.grab_zone.rope_part:
		player.change_state("rope")
