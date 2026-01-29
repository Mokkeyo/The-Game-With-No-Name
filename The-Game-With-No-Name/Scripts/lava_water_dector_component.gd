extends Area2D
class_name LavaWaterDetector

signal water_exited
signal lava_entered
signal water_entered
signal elevator_entered
signal elevator_exited

var inLava: bool = false
var inWater: bool = false
var inWaterElevator: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Lava"):
		lava_entered.emit()
		inLava = true
	if body.is_in_group("Water"):
		inWater = true
		water_entered.emit()
	if body.is_in_group("WaterElevator"):
		elevator_entered.emit()
		inWaterElevator = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		inWater = false
		water_exited.emit()
	if body.is_in_group("WaterElevator"):
		elevator_exited.emit()
		inWaterElevator = false
	if body.is_in_group("Lava"):
		inLava = false
