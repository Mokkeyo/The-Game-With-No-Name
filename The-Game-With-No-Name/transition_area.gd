extends Area2D
class_name TransitionArea

@onready var level_trans: LevelTransition = $LeveltransitionComponent

@export var door_name: String = ""
@export var level_number: int = 1

func _ready() -> void:
	level_trans.door_name = door_name
	level_trans.level_number = level_number


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		level_trans.transition()
