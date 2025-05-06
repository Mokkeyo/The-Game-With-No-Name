extends Node2D
class_name Npc

@export var npcArea: NpcArea
@export var dialogLoader: DialogLoader


func end_dialog() -> void: pass
func on_yes_pressed() -> void: pass
func on_no_pressed() -> void: pass
