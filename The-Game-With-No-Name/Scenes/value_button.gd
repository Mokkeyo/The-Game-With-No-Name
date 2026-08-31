extends Menu_Button
class_name ValueButton

signal value_changed(value: int)

@export var left_value_button: TextureButton
@export var right_value_button: TextureButton
@export var timer: Timer

@export_category("values")
@export var max_value: int = 0
@export var min_value: int = 0
@export var value_steps: int = 1

@export_category("timer")
@export var wait_time: float = 0.2

var direction: int = 0
var current_value: int = 0
var is_holding: bool = false


func _ready() -> void:
	super._ready()
	set_process_input(false)
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)

	left_value_button.button_down.connect(_on_button_down.bind(-1))
	left_value_button.button_up.connect(_on_button_up)

	right_value_button.button_down.connect(_on_button_down.bind(1))
	right_value_button.button_up.connect(_on_button_up)

	focus_entered.connect(set_process_input.bind(true))
	focus_exited.connect(set_process_input.bind(false))


func _input(event: InputEvent) -> void:
	var dir: int = 0
	if event.is_action_pressed("ui_right"):
		dir = 1
	elif event.is_action_pressed("ui_left"):
		dir = -1
	elif event.is_action_released("ui_left"):
		dir = 0
		_on_button_up()
		return
	elif event.is_action_released("ui_right"):
		_on_button_up()
		return
	if dir != 0:
		_on_button_down(dir)

	
func _on_button_down(value: int) -> void:
	direction = value
	is_holding = true

	update_value()

	if is_holding and can_change():
		timer.start()


func _on_button_up() -> void:
	is_holding = false
	self.grab_focus()
	direction = 0

	timer.stop()


func _on_timer_timeout() -> void:
	if not is_holding or direction == 0:
		timer.stop()
		return

	if not can_change():
		print("cant change")
		_on_button_up()
		return

	update_value()

	if is_holding and can_change():
		timer.start()


func update_value() -> void:
	if direction == 0:
		return

	var next: int = current_value + direction * value_steps

	if next < min_value or next > max_value:
		_on_button_up()
		return

	current_value = next

	update_ui()
	value_changed.emit(current_value)


func can_change() -> bool:
	if direction == 0:
		return false

	var next: int = current_value + direction * value_steps

	return next >= min_value and next <= max_value


func update_ui() -> void:
	left_value_button.visible = current_value > min_value
	right_value_button.visible = current_value < max_value
