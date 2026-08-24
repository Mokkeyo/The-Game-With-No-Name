extends PlayerState
class_name WaterAirState

func enter() -> void:
	animation.play(animation.Anim.JUMP)
	player.velocity.y = max(player.velocity.y, - movement.water_jump_power)

func handle_input() -> void:
	var dir: Vector2 = input_direction()
	
	update_combat(dir)
	
	movement.move_horizontal_water(
		dir.x, 
		combat.is_attacking()
	)
	
	update_flip(dir)
	
	if input.jump_pressed():
		animation.play(animation.Anim.JUMP)
		water_jump()


func physics_update(delta: float) -> void:
	movement.apply_water_gravity(
		delta, 
		combat.is_attacking()
	)
	
	if player.velocity.y > 20:
		animation.play(animation.Anim.FALL)
	
	player.move_and_slide()
	
	if player.lava_water_detector.in_water_elevator:
		player.state_machine.change_state(PlayerStates.ID.ELEVATOR)
		return
	
	if player.is_on_floor():
		player.state_machine.change_state(PlayerStates.ID.WATER_GROUND)
		return
	
	if not player.lava_water_detector.in_water:
		player.state_machine.change_state(PlayerStates.ID.AIR)
		AudioManager.play_sfx(Sounds.WATER_ENTER, player.global_position)
