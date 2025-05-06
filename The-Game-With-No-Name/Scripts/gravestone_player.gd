extends Npc

func _unhandled_input(_event: InputEvent) -> void:
	if npcArea.check_for_player():
		dialogLoader.player = npcArea.player
		dialogLoader.start_dialogue_no_check()


func end_dialog() -> void:
	if not dialogLoader.player:
		return
	
	dialogLoader.finish_dialogue()
	dialogLoader.check_for_dialog_collected_no_check()
	
	var achievmentComponent: AchievmentComponent = $achievmentComponent
	
	achievmentComponent.add_achievment()
	get_tree().change_scene_to_file("res://Szenen/Credits.tscn")
