extends PlayerState

func enter() -> void:
	player.can_doublejump = true
	player.play_animation(player.player_strings["idle"])

func handle_input() -> void:
	if Input.is_action_just_pressed(player.inputs["jump"]):
		player.change_state("jump")

func physics_update(_delta: float) -> void:
	var dir: int = int(Input.is_action_pressed(player.inputs["left"])) \
				- int(Input.is_action_pressed(player.inputs["right"]))
	
	if dir == 0:
		player.velocity.x = lerp(player.velocity.x, 0.0, 0.4)
		player.play_animation(player.player_strings["idle"])
	else:
		player.velocity.x += dir * player.ACCELERATION
		player.velocity.x = clamp(player.velocity.x, -player.SPEED, player.SPEED)
		player.play_animation(player.player_strings["walk"])
	
	player.move_and_slide()
	
	if not player.on_floor:
		player.change_state("air")
