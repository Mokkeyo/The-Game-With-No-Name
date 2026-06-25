extends Npc

func _ready() -> void:
	var d_loader: DialogLoader = $DialogueLoader
	d_loader.ending_dialog.connect(end_dialog)

func end_dialog() -> void:
	var achievmentComponent: AchievmentComponent = $achievmentComponent
	
	G.game_finished.emit()
	
	achievmentComponent.add_achievment()
	
	Save.player.finished[0] = true
	Save.save_options()
	
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
