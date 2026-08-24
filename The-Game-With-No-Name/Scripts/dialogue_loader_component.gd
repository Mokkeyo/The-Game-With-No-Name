extends Node2D
class_name DialogLoader

signal ending_dialog

@export var npc_area: NpcArea = null
@export var check_for_input: bool = true

@export_category("dialog system")
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "kratos"

var speaker: String
var dialog: Array

func _ready() -> void:
	set_process_unhandled_input(check_for_input)


func _unhandled_input(_event: InputEvent) -> void:
	if npc_area == null:
		return
	
	if npc_area.player == null:
		return
	
	if npc_area.player.is_in_state(PlayerStates.ID.FREEZE):
		return
	
	if npc_area.check_for_player():
		action()

func action(player: Player = null) -> void:
	if npc_area and player == null:
		player = npc_area.player
	
	if player == null:
		push_warning("no player found inside: ", get_parent().name)
		return
	
	G.start_new_dialog.emit(self, dialogue_resource, dialogue_start)
	player.velocity.x = 0
	player.animation.play(player.animation.Anim.DOOR)
	player.freeze()


func end_dialog() -> void:
	ending_dialog.emit()
