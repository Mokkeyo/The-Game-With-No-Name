extends Node
class_name PlayerInput

var inputs: Dictionary[String, String]
var is_walljumping: bool = false

func set_walljumping() -> void:
	is_walljumping = true

func setup(input_map: Dictionary) -> void:
	inputs = input_map

func move_dir() -> int:
	return int(Input.is_action_pressed(inputs["right"])) \
		 - int(Input.is_action_pressed(inputs["left"]))

func jump_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["jump"])

func jump_released() -> bool:
	return Input.is_action_just_released(inputs["jump"])

func attack_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["attack"])

func wand_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["wand"])

func interact_pressed() -> bool:
	return Input.is_action_just_pressed(inputs["interact"])
