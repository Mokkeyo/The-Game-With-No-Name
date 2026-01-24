extends PlayerState

func enter() -> void:
	player.velocity.y = -player.JUMP_POWER
	player.play_animation(player.player_strings["jump"])

func physics_update(delta: float) -> void:
	var dir: int = int(Input.is_action_pressed(player.inputs["left"])) \
				- int(Input.is_action_pressed(player.inputs["right"]))
	
	player.velocity.x += dir * player.ACCELERATION * 0.5
	player.velocity.x = clamp(player.velocity.x, -player.SPEED, player.SPEED)
	
	
	player.apply_gravity(delta)
	player.move_and_slide()
	
	if player.velocity.y > 0:
		player.change_state("air")
