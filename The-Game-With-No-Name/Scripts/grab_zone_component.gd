extends Area2D
class_name GrabZone

@export var player: Player = null
var can_grab: bool = true
var rope_part: Area2D = null
@onready var timer: Timer = $Timer

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Rope") and can_grab:
		rope_part = area
		can_grab = false

func _on_timer_timeout() -> void:
	can_grab = true
	player.can_doublejump = true
