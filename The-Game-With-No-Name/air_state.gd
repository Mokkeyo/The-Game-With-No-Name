extends PlayerState
var coyote: float = 0.12
var buffer: float = 0.0

func enter() -> void:
	coyote = 0.12
	player.play_animation(player.player_strings["fall"])

func handle_input() -> void:
	if Input.is_action_just_pressed(player.inputs["jump"]):
		buffer = 0.14

func physics_update(delta: float) -> void:
	coyote = max(coyote - delta, 0.0)
	buffer = max(buffer - delta, 0.0)
	
	var dir: int = int(Input.is_action_pressed(player.inputs["left"])) \
				- int(Input.is_action_pressed(player.inputs["right"]))
	
	player.velocity.x += dir * player.ACCELERATION * 0.5
	player.velocity.x = clamp(player.velocity.x, -player.SPEED, player.SPEED)
	
	player.apply_gravity(delta)
	player.move_and_slide()
	
	if player.is_on_wall() and player.velocity.y > 0:
		player.change_state("wall")
		return
	
	if buffer > 0 and (coyote > 0 or player.can_doublejump):
		if coyote <= 0:
			player.can_doublejump = false
		player.change_state("jump")
		return
	
	if player.on_floor:
		player.change_state("ground")
