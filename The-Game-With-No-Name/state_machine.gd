extends Node
class_name StateMachine

var player: Player
var current_state: PlayerState

@onready var states: Array[PlayerState] = [
	$GroundState,
	$AirState,
	$RopeState,
	$LaunchState,
	$WaterElevatorState,
	$WaterGroundState,
	$WaterAirState,
]

func setup(player_value: Player) -> void:
	assert(player_value)
	player = player_value
	
	for state: PlayerState in states:
		state.player = player
		state.movement = player.movement
		state.animation = player.animation
		state.combat = player.combat
		state.input = player.input

func change_state(state: int) -> void:
	var new_state: PlayerState = states[state]
	
	if current_state == new_state:
		return
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()


func physics_update(delta: float) -> void:
	if current_state == null:
		return
	
	current_state.handle_input()
	current_state.physics_update(delta)
