extends Area2D
class_name LavaWaterDetector

signal water_entered(b: bool)
signal lava_entered(b: bool)
signal elevator_entered(b: bool)


var in_lava: bool = false
var in_water: bool = false
var in_water_elevator: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Lava"):
		in_lava = true
		lava_entered.emit(true)
	if body.is_in_group("Water"):
		in_water = true
		water_entered.emit(true)
	if body.is_in_group("WaterElevator"):
		in_water_elevator = true
		elevator_entered.emit(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		in_water = false
		water_entered.emit(false)
	if body.is_in_group("WaterElevator"):
		in_water_elevator = false
		water_entered.emit(false)
	if body.is_in_group("Lava"):
		in_lava = false
		lava_entered.emit(false)
