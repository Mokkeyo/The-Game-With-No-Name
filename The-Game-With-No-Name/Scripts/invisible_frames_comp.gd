extends Node
class_name InvisibleFramesComp

@onready var timer: Timer = $Timer
@export var parent: Node2D

var is_active: bool = false
var duration: float
var counter: int
var blink_speed: float = 0.1
var blink_count: int = 0

func _ready() -> void:
	if parent == null:
		parent = get_parent()


func play_invible_frames(timer_duration: float) -> void:
	if is_active or parent  == null:
		return
	duration = timer_duration
	is_active = true
	blink_count = int(duration / blink_speed)
	counter = 0
	play()

func play() -> void:
	timer.start(blink_speed)


func _on_timer_timeout() -> void:
	if counter >= blink_count:
		reset_invisible_frames()
		return
	
	# Zwischen 0.1 und 1.0 wechseln
	parent.visible = false if parent.visible else true
	counter += 1
	timer.start(blink_speed)


func reset_invisible_frames() -> void:
	timer.stop()
	parent.visible = true
	is_active = false
