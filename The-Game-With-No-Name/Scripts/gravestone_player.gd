extends Npc


func end_dialog() -> void:
	var achievmentComponent: AchievmentComponent = $achievmentComponent
	
	achievmentComponent.add_achievment()
	
	Save.player.finished[0] = true
	Save.save_options()
	
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
