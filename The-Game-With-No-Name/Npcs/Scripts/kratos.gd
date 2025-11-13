extends Npc

func _unhandled_input(_event: InputEvent) -> void:
	if npcArea.check_for_player():
		dialogLoader.player = npcArea.player
		dialogLoader.start_dialogue(G.save_stat.kristallCount)


func end_dialog() -> void:
	if dialogLoader.player:
		dialogLoader.finish_dialogue()
		dialogLoader.check_for_dialog_collected(G.save_stat.kristallCount)
