extends Area2D
class_name LavaWaterDetector

signal water_exited
signal lava_entered

var inLava: bool = false
var inWater: bool = false
var inWaterElevator: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Lava"):
		emit_signal("lava_entered")
		inLava = true
	if body.is_in_group("Water"):
		inWater = true
	if body.is_in_group("WaterElevator"):
		inWaterElevator = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		inWater = false
		emit_signal("water_exited")
	if body.is_in_group("WaterElevator"):
		inWaterElevator = false
	if body.is_in_group("Lava"):
		inLava = false
