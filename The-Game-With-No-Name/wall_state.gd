extends PlayerState

func handle_input() -> void:
	if Input.is_action_just_pressed(player.inputs["jump"]):
		var dir: float = -sign(player.get_wall_normal().x)
		player.velocity = Vector2(dir * 180, -260)
		player.change_state("air")
		player.can_doublejump = true

func physics_update(delta: float) -> void:
	player.velocity.y = min(player.velocity.y + player.GRAVITY * delta * 0.4, 120)
	player.move_and_slide()

	if player.is_on_floor():
		player.change_state("ground")
	elif not player.is_on_wall():
		player.change_state("air")
