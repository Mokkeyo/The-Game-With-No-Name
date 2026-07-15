extends Node
class_name StateMachine

var player: Player
var current_state: PlayerState
var current_id: PlayerStates.ID

@onready var states: Array[PlayerState] = [
	$GroundState,
	$AirState,
	$RopeState,
	$LaunchState,
	$WaterElevatorState,
	$WaterGroundState,
	$WaterAirState,
	$FreezeState,
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

func change_state(id: PlayerStates.ID) -> void:
	var new_state: PlayerState = states[id]
	
	if current_state == new_state:
		return
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_id = id
	current_state.enter()


func physics_update(delta: float) -> void:
	if current_state == null:
		return
	
	current_state.handle_input()
	current_state.physics_update(delta)

func is_in_state(id: PlayerStates.ID) -> bool:
	return current_id == id
