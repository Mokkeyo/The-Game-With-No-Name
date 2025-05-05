extends Npc
@export var number: int = 0

func _unhandled_input(_event: InputEvent) -> void:
	if npcArea.check_for_player():
		dialogLoader.player = npcArea.player
		dialogLoader.start_dialogue(number)


func end_dialog() -> void:
	if dialogLoader.player:
		dialogLoader.finish_dialogue()
		dialogLoader.check_for_dialog_collected(number)
