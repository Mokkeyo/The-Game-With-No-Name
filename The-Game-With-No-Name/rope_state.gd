extends PlayerState
class_name RopeState

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.animation.play(player.animation.Anim.JUMP)


func handle_input() -> void:
	if Input.is_action_just_pressed(player.inputs["jump"]):
		player.velocity.y = 0
		player.grab_zone.rope_part = null
		player.grab_zone.cool_down_timer.start()
		player.movement.jump()
		player.change_state("air")
		return

func physics_update(_delta: float) -> void:
	if not player.grab_zone.rope_part:
		player.change_state("air")
		player.can_doublejump = true
		return
	
	player.global_position = \
		player.grab_zone.rope_part.global_position - Vector2(0, -4)
