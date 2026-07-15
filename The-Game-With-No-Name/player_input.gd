extends Node
class_name PlayerInput

var inputs: Dictionary[String, String]

func setup(input_map: Dictionary[String, String]) -> void:
	inputs = input_map

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
