extends Resource
class_name savedInputmap

@export var device:  Array[int] = [0, 1]

@export var inputMap: Dictionary = {
	'player1_up' : InputMap.action_get_events("player1_up")[0],
	'player1_down' : InputMap.action_get_events("player1_down")[0],
	'player1_left': InputMap.action_get_events('player1_left')[0],
	'player1_right' : InputMap.action_get_events("player1_right")[0],
	'player1_jump': InputMap.action_get_events('player1_jump')[0],
	'player1_attack' : InputMap.action_get_events("player1_attack")[0],
	"player1_wand" : InputMap.action_get_events("player1_wand")[0],
	"player1_interact" : InputMap.action_get_events("player1_interact")[0],
	"player1_spawn" : InputMap.action_get_events("player1_spawn")[0],

	'C-player1_up' : InputMap.action_get_events("C-player1_up")[0],
	'C-player1_down' : InputMap.action_get_events("C-player1_down")[0],
	'C-player1_left': InputMap.action_get_events('C-player1_left')[0],
	'C-player1_right' : InputMap.action_get_events("C-player1_right")[0],
	'C-player1_jump': InputMap.action_get_events('C-player1_jump')[0],
	'C-player1_attack' : InputMap.action_get_events("C-player1_attack")[0],
	"C-player1_wand" : InputMap.action_get_events("C-player1_wand")[0],
	"C-player1_interact" : InputMap.action_get_events("C-player1_interact")[0],
	"C-player1_spawn" : InputMap.action_get_events("C-player1_spawn")[0],

	'player2_jump': InputMap.action_get_events('player2_jump')[0],
	'player2_left': InputMap.action_get_events('player2_left')[0],
	'player2_right' : InputMap.action_get_events("player2_right")[0],
	'player2_up' : InputMap.action_get_events("player2_up")[0],
	'player2_down' : InputMap.action_get_events("player2_down")[0],
	'player2_attack' : InputMap.action_get_events("player2_attack")[0],
	"player2_wand" : InputMap.action_get_events("player2_wand")[0],
	"player2_interact" : InputMap.action_get_events("player2_interact")[0],
	"player2_spawn" : InputMap.action_get_events("player2_spawn")[0],

	'C-player2_jump': InputMap.action_get_events('C-player2_jump')[0],
	'C-player2_left': InputMap.action_get_events('C-player2_left')[0],
	'C-player2_right' : InputMap.action_get_events("C-player2_right")[0],
	'C-player2_up' : InputMap.action_get_events("C-player2_up")[0],
	'C-player2_down' : InputMap.action_get_events("C-player2_down")[0],
	'C-player2_attack' : InputMap.action_get_events("C-player2_attack")[0],
	"C-player2_wand" : InputMap.action_get_events("C-player2_wand")[0],
	"C-player2_interact" : InputMap.action_get_events("C-player2_interact")[0],
	"C-player2_spawn" : InputMap.action_get_events("C-player2_spawn")[0],
}
