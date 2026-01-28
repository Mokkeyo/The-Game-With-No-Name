extends PlayerState
class_name GroundState


func enter() -> void:
	player.can_doublejump = true
	player.animation.play(player.animation.Anim.IDLE)

func handle_input() -> void:
	var dir: int = player.input.move_dir()
	
	player.movement.move_horizontal(
		dir, 
		not player.combat.can_attack()
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
	
	if Input.is_action_just_pressed(player.inputs["interact"]):
		player.handle_airship_entry()

func physics_update(_delta: float) -> void:
	player.rotater_component.update_rotation()
	
	player.floor_snap_length = 15 if player.is_on_floor() else 0
	
	if not player.is_on_floor():
		player.coyote_timer.start(0.15)
		player.change_state("air")
