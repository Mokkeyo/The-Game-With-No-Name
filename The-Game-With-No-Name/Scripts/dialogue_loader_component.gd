extends Node2D
class_name DialogLoader

signal ending_dialog

@export var interaction_area: InteractionArea = null
@export var check_for_input: bool = true

@export_category("dialog system")
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "kratos"

var speaker: String
var dialog: Array

func _ready() -> void:
	if not interaction_area:
		push_warning("no interaction area connected to: ", self)
		return

	interaction_area.interacted.connect(action)


func action(player: Player = null) -> void:
	if player == null:
		push_warning("no player found inside: ", get_parent().name)
		return
	
	if G.dialog_active:
		return

	G.start_new_dialog.emit(self, dialogue_resource, dialogue_start)
	player.velocity.x = 0
	player.animation.play(player.animation.Anim.DOOR)
	player.freeze()


func end_dialog() -> void:
	ending_dialog.emit()
