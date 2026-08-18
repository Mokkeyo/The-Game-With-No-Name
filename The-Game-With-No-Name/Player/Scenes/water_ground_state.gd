extends PlayerState
class_name WaterGroundState


func handle_input() -> void:
	var dir: Vector2 = input_direction()
	
	update_combat(dir)
	
	movement.move_horizontal_water(
		dir.x, 
		combat.is_attacking()
	)
	
	update_flip(dir)
	
	if dir.x != 0:
		animation.play(animation.Anim.WALK)
	else:
		animation.play(animation.Anim.IDLE)
	
	if not input.jump_pressed():
		return
	
	animation.play(animation.Anim.JUMP)
	
	water_jump()


func physics_update(_delta: float) -> void:
	update_ground_state()
	
	if player.lava_water_detector.in_water_elevator:
		player.rotation_degrees = 0.0
		player.state_machine.change_state(PlayerStates.ID.ELEVATOR)
		return
	
	if not player.is_on_floor():
		player.rotation_degrees = 0.0
		player.state_machine.change_state(PlayerStates.ID.WATER_AIR)
		return
	
	if not player.lava_water_detector.in_water:
		player.state_machine.change_state(PlayerStates.ID.GROUND)
		AudioManager.play_sfx(Sounds.WATER_ENTER, player.global_position)
		return
