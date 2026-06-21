extends Node2D
class_name AchievmentComponent

@export_enum("Unkillable", "Chatter", "Its Just The Beginning", "You Got A Friend In Me", 
"Does Someone Need A Tutorial?", "Secret With No Name") var achievment_list: String

func add_achievment() -> void:
	if not Save.options.achievments.has(achievment_list):
		Save.options.achievments.append(achievment_list)
#		AI._on_achievement_collected(achievment_list)
		Save.save_options()
