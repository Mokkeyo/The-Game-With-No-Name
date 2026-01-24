extends PlayerState

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("jump")


func handle_input() -> void:
	if Input.is_action_just_pressed(player.inputs["jump"]):
		player.velocity.y = 0
		player.grabZone.rope_part = null
		player.grabZone.timer.start()
		player.jump(player.JUMP_POWER)
		player.change_state("air")
		return

func physics_update(_delta: float) -> void:
	if not player.grabZone.rope_part:
		player.change_state("air")
		return
	
	player.global_position = \
		player.grabZone.rope_part.global_position - Vector2(0, -4)
