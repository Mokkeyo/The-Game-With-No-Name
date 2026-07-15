extends Node
class_name PlayerInput

var inputs: Dictionary[String, String]

func setup(player_index: int) -> void:
	inputs = {
		"up": "player%d_up" % int(player_index),
		"down": "player%d_down" % int(player_index),
		"left": "player%d_left" % int(player_index),
		"right": "player%d_right" % int(player_index),
		"jump": "player%d_jump" % int(player_index),
		"interact": "player%d_interact" % int(player_index),
		"attack": "player%d_attack" % int(player_index),
		"wand": "player%d_wand" % int(player_index)
	}

#region Movement
func move_dir() -> int:
	return int(Input.is_action_pressed(inputs["right"])) \
		 - int(Input.is_action_pressed(inputs["left"]))

func y_dir() -> int:
	return int(Input.is_action_pressed(inputs["down"])) \
		 - int(Input.is_action_pressed(inputs["up"]))
#endregion

#region Jump
func jump_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["jump"])

func jump_released() -> bool:
	return Input.is_action_just_released(inputs["jump"])
#endregion

#region Actions
func attack_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["attack"])

func wand_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["wand"])

func interact_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["interact"])
#endregion
