extends Node

var jump: Array[StringName] = ["player1_jump", "player2_jump","C-player1_jump","C-player2_jump"]
var up: Array[StringName] = ["player1_up", "player2_up","C-player1_up","C-player2_up"]
var down: Array[StringName] = ["player1_down", "player2_down","C-player1_down","C-player2_down"]
var left: Array[StringName] = ["player1_left", "player2_left","C-player1_left","C-player2_left"]
var right: Array[StringName] = ["player1_right", "player2_right","C-player1_right","C-player2_right"]
var attack: Array[StringName] = ["player1_attack", "player2_attack","C-player1_attack","C-player2_attack"]
var wand: Array[StringName] = ["player1_wand", "player2_wand","C-player1_wand","C-player2_wand"]
var interact: Array[StringName] = ["player1_interact", "player2_interact","C-player1_interact","C-player2_interact"]
var spawn: Array[StringName] = ["player1_spawn", "player2_spawn","C-player1_spawn","C-player2_spawn"]

func released(inputs: Array[StringName], player: int) -> bool:
	if Input.is_action_just_released(inputs[player]) or Input.is_action_just_released(inputs[player+2]):
		return true
	return false


func pressed(inputs: Array[StringName], currentPlayer: int) -> bool:
	if Input.is_action_pressed(inputs[currentPlayer]) or Input.is_action_pressed(inputs[currentPlayer +2]):
		return true
	return false


func just_pressed(inputs: Array[StringName], currentPlayer: int) -> bool:
	if Input.is_action_just_pressed(inputs[currentPlayer]) or Input.is_action_just_pressed(inputs[currentPlayer +2]):
		return true
	return false
