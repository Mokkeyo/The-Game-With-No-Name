extends Area2D
class_name GrabZone

signal grabbed_rope(rope: Area2D)
signal release_rope

var can_grab: bool = true
var rope_part: Area2D = null
var memorized_rope: Node2D

@onready var forget_timer:  Timer = $ForgetTimer
@onready var cool_down_timer: Timer = $CooldownTimer

func _on_area_entered(area: Area2D) -> void:
	if not can_grab:
		return
	
	if not area.is_in_group("Rope"):
		return
		
	if area.get_parent() == memorized_rope:
		return
		
	rope_part = area
	memorized_rope = area.get_parent()
	can_grab = false
	grabbed_rope.emit(area)


func release() -> void:
	rope_part = null
	cool_down_timer.start()
	release_rope.emit()


func _on_cooldown_timer_timeout() -> void:
	can_grab = true
	forget_timer.start()


func _on_forget_timer_timeout() -> void:
	memorized_rope = null
