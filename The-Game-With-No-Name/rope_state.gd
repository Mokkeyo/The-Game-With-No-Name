extends PlayerState
class_name RopeState

signal entered_rope
signal exited_rope

const ROPE_OFFSET: Vector2 = Vector2(0, -10)

func enter() -> void:
	player.velocity = Vector2.ZERO
	animation.play(animation.Anim.JUMP)
	entered_rope.emit()


func handle_input() -> void:
	var dir: Vector2 = input_direction()
	
	update_combat(dir)
	
	update_flip(dir)
	
	if input.jump_pressed():
		jump()
		exited_rope.emit()
		
		player.grab_zone.rope_part = null
		player.grab_zone.cool_down_timer.start()



func physics_update(_delta: float) -> void:
	var rope_part: Area2D = player.grab_zone.rope_part
	
	if rope_part == null:
		player.state_machine.change_state(PlayerStates.ID.AIR)
		return
	
	player.global_position = rope_part.global_position - ROPE_OFFSET
