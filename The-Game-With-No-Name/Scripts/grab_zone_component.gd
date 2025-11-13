extends Area2D
class_name GrabZone

@export var player: Player = null
var can_grab: bool = true
var rope_part: Area2D = null
var memorized_rope: Node2D
@onready var forget_rope_timer:  Timer = $Timer2
@onready var timer: Timer = $Timer

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Rope") and can_grab and not area.get_parent() == memorized_rope:
		rope_part = area
		memorized_rope = area.get_parent()
		can_grab = false

func _on_timer_timeout() -> void:
	can_grab = true
	player.can_doublejump = true
	forget_rope_timer.start()

func _on_timer_2_timeout() -> void:
	memorized_rope = null
