extends PlayerState

var dir: float

func enter() -> void:
	player.can_doublejump = true
	player.play_animation(player.player_strings["idle"])

func handle_input() -> void:
	dir = int(Input.is_action_pressed(player.inputs["left"])) \
		- int(Input.is_action_pressed(player.inputs["right"]))
	
	if Input.is_action_just_pressed(player.inputs["jump"]):
		player.jump(player.JUMP_POWER)
		player.change_state("air")
	
	if Input.is_action_just_pressed(player.inputs["attack"]):
		player.sword.attack()

	if Input.is_action_just_pressed(player.inputs["wand"]):
		player.cast_spell()

func physics_update(_delta: float) -> void:
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
