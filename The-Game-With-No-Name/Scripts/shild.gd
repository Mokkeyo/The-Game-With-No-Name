extends Node2D

@export var shildNumber: int = 0
@onready var dialog_loader: DialogLoader = $DialogueLoader
@onready var npc_area: NpcArea = $NPCArea

func _unhandled_input(_event: InputEvent) -> void:
	G.dialog_index = shildNumber
	if npc_area.check_for_player():
		dialog_loader.action()
