extends PlayerState
class_name GroundState

@export var footstep_sound: FootStepComp
const FOOTSTEP_FRAMES: Array[int] = [2, 4, 6]

func exit() -> void:
	player.rotater_component.rotate_sprite(0)


func play_walk_sound() -> void:
	var sprite: AnimatedSprite2D = animation.sprite
	if sprite.animation != "walk_%d" % player.current_player:
		return
	
	if sprite.frame in FOOTSTEP_FRAMES:
		SoundComp.play_footstep(player.global_position)


func handle_input() -> void:
	var dir: Vector2 = input_direction()
	
	update_combat(dir)
	
	movement.move_horizontal_normal(
		dir.x, 
		combat.is_attacking()
	)
	
	update_flip(dir)
	
	if dir.x != 0:
		animation.play(animation.Anim.WALK)
		play_walk_sound()
	else:
		animation.play(animation.Anim.IDLE)
	
	if input.jump_pressed():
		jump()
		return
	
	if input.interact_pressed():
		player.airship_entry_component.handle_airship_entry()


func physics_update(_delta: float) -> void:
	update_ground_state()
	
	if player.lava_water_detector.in_water:
		player.state_machine.change_state(PlayerStates.ID.WATER_GROUND)
		return
	
	if not player.is_on_floor():
		player.rotation_degrees = 0
		player.state_machine.change_state(PlayerStates.ID.AIR)
