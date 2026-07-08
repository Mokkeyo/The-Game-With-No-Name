extends Node2D
class_name Test

var battle_data: BattleData = BattleData.new()

func _physics_process(_delta: float) -> void:
	battle_data.hp[0] += 10
	print(name, " : ", battle_data.hp)
	
	if battle_data.hp[0] < 60:
		get_tree().change_scene_to_file("res://test_2.tscn")
	set_physics_process(false)
