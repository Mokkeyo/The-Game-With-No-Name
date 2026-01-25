extends PlayerState

func enter() -> void:
	player.play_animation("fall")

func handle_input() -> void:
	var dir: int = int(Input.is_action_pressed(player.inputs["right"])) \
				- int(Input.is_action_pressed(player.inputs["left"]))
	
	player.move_horizontal(dir)
	if not dir == 0:
		player.flip_sprite(dir < 0)
	
	if Input.is_action_just_pressed(player.inputs["attack"]):
		player.sword.attack()
	
	if Input.is_action_just_pressed(player.inputs["wand"]):
		player.wand.attack()
	
	if Input.is_action_just_released(player.inputs["jump"]):
		if player.velocity.y < -100:
			player.velocity.y = -100


	if not Input.is_action_just_pressed(player.inputs["jump"]):
		return
	
	player.velocity.y = 0
	player.play_animation("jump")
	
	if player.lavaWaterDetector.inWater:
		player.jump(player.WATER_JUMP)
		return
	
	if not player.coyoteTimer.is_stopped():
		player.jump(player.JUMP_POWER)
		player.coyoteTimer.stop()
		return
	
	if player.next_to_wall():
		player.do_walljump()
		return
	
	if player.can_doublejump:
		player.can_doublejump = false
		player.jump(player.JUMP_POWER)
		return
	
	player.buffered_jump = true
	player.jumpBufferTimer.start(0.15)

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	
	if player.velocity.y > 0:
		player.play_animation("fall")
	
	if player.is_on_floor():
		if player.buffered_jump:
			player.buffered_jump = false
			player.jump(player.JUMP_POWER)
			return
		player.change_state("ground")
		return
	
	if player.grabZone.rope_part:
		player.change_state("rope")
