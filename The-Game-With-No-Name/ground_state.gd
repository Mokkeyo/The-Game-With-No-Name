extends PlayerState
class_name GroundState

var dir: Vector2
@export var footstep_sound: FootStepComp

func enter() -> void:
	player.can_doublejump = true
	player.animation.play(player.animation.Anim.IDLE)
	player.floor_snap_length = 15
	player.position.y = roundi(player.position.y)

func exit() -> void:
	player.rotater_component.rotate_sprite(0)
	player.floor_snap_length = 0
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
		player.animation.play(player.animation.Anim.WALK)
		
	else:
		player.animation.play(player.animation.Anim.IDLE)
	
	if player.input.jump_pressed():
		player.sound_player.sound = "jump"
		player.sound_player.play_sound()
		player.movement.jump()
		player.change_state("air")
		return
	
	if player.input.attack_pressed():
		player.combat.attack()
	
	if player.input.wand_pressed():
		player.combat.cast()
	
	if player.input.interact_pressed():
		player.handle_airship_entry()

func physics_update(_delta: float) -> void:
	player.rotater_component.update_rotation()
	player.combat.change_sword_direction(dir, player.animated_sprite.rotation_degrees)
	var on_moving_plattform: bool = player.get_platform_velocity().length() > 0.01
	var is_flat: bool = player.get_floor_angle() == 0
	
	if not on_moving_plattform and is_flat:
		player.position.y = roundi(player.position.y)
	
	player.move_and_slide()
	
	if not player.is_on_floor():
		player.coyote_timer.start(0.15)
		player.change_state("air")
