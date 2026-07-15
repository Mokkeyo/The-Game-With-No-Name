extends Node2D
class_name Test2

var battle_data: BattleData = BattleData.new()

func _physics_process(_delta: float) -> void:
	BattleData.hp += 10
	
	if BattleData.hp < 60:
		get_tree().change_scene_to_file("res://test.tscn")
	set_physics_process(false)
