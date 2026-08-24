extends PlayerState
class_name GroundState

const FOOTSTEP_FRAMES: Array[int] = [2, 4, 6]

func exit() -> void:
	player.rotater_component.rotate_sprite(0)


func handle_input() -> void:
	var direction: Vector2 = input_direction()
	
	update_combat(direction)
	update_movement(direction)
	update_animation(direction.x)
	handle_actions()


func update_movement(direction: Vector2) -> void:
	movement.move_horizontal_normal(
		direction.x, 
		combat.is_attacking()
	)
	
	update_flip(direction)


func update_animation(direction_x: float) -> void:
	if direction_x == 0:
		animation.play(animation.Anim.IDLE)
		return
	
	animation.play(animation.Anim.WALK)


func handle_actions() -> void:
	if input.jump_pressed():
		AudioManager.play_sfx(Sounds.PLAYER_JUMP, player.global_position)
		jump()
		return
	
	if input.interact_pressed():
		player.airship_entry_component.handle_airship_entry()


func physics_update(_delta: float) -> void:
	update_ground_state()
	
	if player.lava_water_detector.in_water:
		enter_water()
		return
	
	if not player.is_on_floor():
		enter_air()


func enter_water() -> void:
	player.state_machine.change_state(
		PlayerStates.ID.WATER_GROUND
	)
	
	AudioManager.play_sfx(
		Sounds.WATER_ENTER, 
		player.global_position
	)


func enter_air() -> void:
	player.rotation_degrees = 0.0
	player.state_machine.change_state(PlayerStates.ID.AIR)


func _on_animated_sprite_2d_frame_changed() -> void:
	if animation.sprite.animation != "walk_%d" % player.current_player:
		return
	
	if animation.sprite.frame not in FOOTSTEP_FRAMES:
		return
	
	AudioManager.play_sfx(
		Sounds.PLAYER_WALKING,
		player.global_position
	)
