extends Npc

var index: int = 0

func _unhandled_input(_event: InputEvent) -> void:
	if npcArea.check_for_player():
		dialogLoader.player = npcArea.player
		if dialogLoader.has_dialog(D.rick, 2):
			index = 1
		dialogLoader.start_dialogue(index)


func end_dialog() -> void:
	if dialogLoader.player:
		dialogLoader.finish_dialogue()
		dialogLoader.check_for_dialog_collected(index)
