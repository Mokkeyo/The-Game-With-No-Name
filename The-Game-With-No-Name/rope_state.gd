extends PlayerState
class_name RopeState

signal entered_rope
signal exited_rope

var dir: Vector2

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.animation.play(player.animation.Anim.JUMP)
	entered_rope.emit()


func exit() -> void:
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
	
	if player.input.jump_pressed():
		player.sound_player.sound = "jump"
		player.sound_player.play_sound()
		player.velocity.y = 0
		player.grab_zone.rope_part = null
		player.grab_zone.cool_down_timer.start()
		player.movement.jump()
		player.change_state("air")
		exited_rope.emit()
		return

func physics_update(_delta: float) -> void:
	
	player.combat.change_sword_direction(dir, player.animated_sprite.rotation_degrees)
	
	if not player.grab_zone.rope_part:
		player.change_state("air")
		player.can_doublejump = true
		return
	
	player.global_position = \
		player.grab_zone.rope_part.global_position - Vector2(0, -4)
