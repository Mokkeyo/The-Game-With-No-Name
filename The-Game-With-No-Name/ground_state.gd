extends PlayerState
class_name GroundState


func enter() -> void:
	player.can_doublejump = true
	player.animation.play(player.animation.Anim.IDLE)
	player.floor_snap_length = 15
	player.position.y = roundi(player.position.y)

func exit() -> void:
	player.rotater_component.rotate_sprite(0)
	player.floor_snap_length = 0


func handle_input() -> void:
	var dir: int = player.input.move_dir()
	
	player.movement.move_horizontal(
		dir, 
		player.combat.is_attacking()
		)
		
	if not dir == 0:
		player.animation.flip(dir < 0)
		player.animation.play(player.animation.Anim.WALK)
	else:
		player.animation.play(player.animation.Anim.IDLE)
	
	if player.input.jump_pressed():
		player.movement.jump()
		player.change_state("air")
		return
	
	if player.input.attack_pressed() and player.combat.can_attack():
		player.combat.attack(dir)
	
	if player.input.wand_pressed() and player.combat.can_cast():
		player.combat.cast(dir)
	
	if player.input.interact_pressed():
		player.handle_airship_entry()

func physics_update(_delta: float) -> void:
	player.rotater_component.update_rotation()
	
	var on_moving_plattform: bool = player.get_platform_velocity().length() > 0.01
	var is_flat: bool = player.get_floor_angle() == 0
	
	if not on_moving_plattform and is_flat:
		player.position.y = roundi(player.position.y)
	
	player.move_and_slide()
	
	if not player.is_on_floor():
		player.coyote_timer.start(0.15)
		player.change_state("air")
