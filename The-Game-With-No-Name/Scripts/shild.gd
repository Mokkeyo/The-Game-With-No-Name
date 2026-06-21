extends Npc

@export var shildNumber: int = 0
@onready var npc_area: NpcArea = $NPCArea
@onready var dialogue_loader: DialogLoader = $DialogueLoader

func _unhandled_input(_event: InputEvent) -> void:
	G.dialog_index = shildNumber
	if npc_area.check_for_player():
		dialogue_loader.action()
