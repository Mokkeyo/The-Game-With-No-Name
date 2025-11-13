extends Resource
class_name SavedInputmap

@export var device:  Array[int] = [0, 1]

@export var inputMap: Dictionary[String, Array] = {
	'player1_up': InputMap.action_get_events("player1_up"),
	'player1_down': InputMap.action_get_events("player1_down"),
	'player1_left': InputMap.action_get_events('player1_left'),
	'player1_right': InputMap.action_get_events("player1_right"),
	'player1_jump': InputMap.action_get_events('player1_jump'),
	'player1_attack': InputMap.action_get_events("player1_attack"),
	"player1_wand": InputMap.action_get_events("player1_wand"),
	"player1_interact": InputMap.action_get_events("player1_interact"),
	"player1_spawn": InputMap.action_get_events("player1_spawn"),
	
	'player2_jump': InputMap.action_get_events('player2_jump'),
	'player2_left': InputMap.action_get_events('player2_left'),
	'player2_right' : InputMap.action_get_events("player2_right"),
	'player2_up' : InputMap.action_get_events("player2_up"),
	'player2_down' : InputMap.action_get_events("player2_down"),
	'player2_attack' : InputMap.action_get_events("player2_attack"),
	"player2_wand" : InputMap.action_get_events("player2_wand"),
	"player2_interact" : InputMap.action_get_events("player2_interact"),
	"player2_spawn" : InputMap.action_get_events("player2_spawn"),
}
