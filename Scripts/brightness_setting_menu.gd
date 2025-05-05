extends Menu
class_name Brightness

var change_brightness: bool = true
var wait: bool = false

@onready var brightness_slider: HSlider = $bright
@onready var check_button: CheckButton = $CheckButton
@onready var timer: Timer = $Timer
@onready var darkness_warning: Control = $TurnDarknessOff
@onready var turn_on_button: Button = $TurnDarknessOff/TurnOn

func _ready() -> void:
	super._ready()
	exited.connect(set_visibility)

	brightness_slider.value = G.SaveStatInf.darknessValue
	check_button.button_pressed = G.SaveStatInf.darknessOn


func _unhandled_input(event: InputEvent) -> void:
	if not change_brightness and Input.is_action_just_pressed("escape"):
		exit_darkness_disabler()
	else:
		super._unhandled_input(event)


func set_visibility() -> void:
	visible = false


func exit_darkness_disabler() -> void:
	change_brightness = true
	enter()
	darkness_warning.visible = false


func _on_TurnOn_pressed() -> void:
	G.SaveStatInf.darknessOn = true
	G.emit_signal("darkness_changed")
	G.save_options()
	exit_darkness_disabler()


func _on_TurnOff_pressed() -> void:
	G.SaveStatInf.darknessOn = false
	G.emit_signal("darkness_changed")
	G.save_options()
	
	wait = true
	timer.start()
	check_button.button_pressed = false
	exit_darkness_disabler()


func _on_CheckButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		if not wait:
			G.SaveStatInf.darknessOn = true
			G.emit_signal("darkness_changed")
			G.save_options()
	else:
		change_brightness = false
		darkness_warning.visible = true
		turn_on_button.grab_focus()
		
		if not wait:
			check_button.button_pressed = true


func _on_bright_value_changed(value: int) -> void:
	G.SaveStatInf.darknessValue = value
	G.emit_signal("darkness_changed")
	G.save_options()


func _on_Timer_timeout() -> void:
	wait = false
