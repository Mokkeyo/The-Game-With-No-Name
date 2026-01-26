extends Menu
class_name Options

@export var group: ButtonGroup

@onready var brightness: Brightness = $Brightness
@onready var panel: Control = $Panel
@onready var grafik_options: Control = $GrafikOptions
@onready var option_buttons: Array[Button] = [$Panel/GrafikButton, $Panel/SoundButton, $Panel/EtcButton]
@onready var options_panels: Array[Control] = [$GrafikOptions, $SoundOptions, $EtcOptions]

@onready var wait_timer: Timer = $WaitTimer

var current_menu: int = 0

func _ready() -> void:
	super._ready()
	
	connect("exited", Callable(wait_timer, "start"))
	
	for button: BaseButton in group.get_buttons():
		button.pressed.connect(Callable(self, "buttonpressed"))
	
	brightness.exited.connect(brightness_exited)


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	
	if event.is_pressed() and event is InputEventJoypadButton:
		var button_event: InputEventJoypadButton = event
		match button_event.button_index:
			JOY_BUTTON_LEFT_SHOULDER:
				change_menu(-1)
			JOY_BUTTON_RIGHT_SHOULDER:
				change_menu(1)


func change_menu(direction: int) -> void:
	var next_menu: int = current_menu + direction
	
	if next_menu < 0 or next_menu >= option_buttons.size():
		return
	
	option_buttons[next_menu].grab_focus()
	change_options(next_menu)


func change_options(index: int) -> void:
	current_menu = index
	
	for i: int in options_panels.size():
		option_buttons[i].disabled = (i == index)
		options_panels[i].visible = (i == index)


func brightness_exited() -> void:
	enter()
	grafik_options.visible = true
	panel.visible = true


func _on_grafik_button_pressed() -> void:
	change_options(0)

func _on_sound_button_pressed() -> void:
	change_options(1)

func _on_etc_button_pressed() -> void:
	change_options(2)

func _on_brightness_button_pressed() -> void:
	set_process_unhandled_input(false)
	grafik_options.visible = false
	panel.visible = false
	brightness.visible = true
	brightness.enter()


func _on_wait_timer_timeout() -> void:
	change_options(0)
