extends Menu
class_name TwoPlayerMode


func _ready() -> void:
	var timer: Timer = $Timer
	exited.connect(timer.start)
	super._ready()


func _on_timer_timeout() -> void:
	hide()
