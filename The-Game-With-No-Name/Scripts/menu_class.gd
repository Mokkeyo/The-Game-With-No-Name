extends Control
class_name Menu

signal exited

@export var startButton: Button
@export var exitButton: Button

func _ready() -> void:
	exitButton.connect("pressed", Callable(self, "exit"))
	set_process_unhandled_input(false)
	set_process_input(false)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		exit()


func enter() -> void:
	set_process_unhandled_input(true)
	set_process_input(true)
	startButton.grab_focus()


func exit() -> void:
	set_process_unhandled_input(false)
	set_process_input(false)
	emit_signal("exited")
