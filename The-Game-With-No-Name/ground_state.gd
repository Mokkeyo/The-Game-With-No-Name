extends PlayerState

var dir: float

func enter() -> void:
	player.can_doublejump = true
	player.play_animation("idle")

func handle_input() -> void:
	dir = int(Input.is_action_pressed(player.inputs["right"])) \
		- int(Input.is_action_pressed(player.inputs["left"]))
	
	player.move_horizontal(dir)
	if not dir == 0:
		player.flip_sprite(dir < 0)
	
	if dir != 0:
		player.play_animation("walk")
	else:
		player.play_animation("idle")
	
	if Input.is_action_just_pressed(player.inputs["jump"]):
		player.jump(player.JUMP_POWER)
		player.change_state("air")
		return
	
	if Input.is_action_just_pressed(player.inputs["attack"]):
		player.sword.attack()
	
	if Input.is_action_just_pressed(player.inputs["wand"]):
		player.wand.attack()
	
	if Input.is_action_just_pressed(player.inputs["interact"]):
		player.handle_airship_entry()

func physics_update(_delta: float) -> void:
	
	if not player.is_on_floor():
		player.coyoteTimer.start(0.15)
		player.change_state("air")
