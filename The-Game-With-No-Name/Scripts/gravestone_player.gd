extends Npc

func _unhandled_input(_event: InputEvent) -> void:
	if npcArea.check_for_player():
		dialogLoader.player = npcArea.player
		dialogLoader.start_dialogue_no_check()


func end_dialog() -> void:
	if not dialogLoader.player:
		return
	
	#await AI.fader.fade_out().animation_finished
	
	dialogLoader.finish_dialogue()
	dialogLoader.check_for_dialog_collected_no_check()
	
	var achievmentComponent: AchievmentComponent = $achievmentComponent
	
	achievmentComponent.add_achievment()
	
	Save.player.finished[0] = true
	Save.save_options()
	
	
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
