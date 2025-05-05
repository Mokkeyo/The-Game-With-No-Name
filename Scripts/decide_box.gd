extends Control
class_name DecideBox

@export var text_box: TextBox
@onready var pings: Array[Sprite2D] = [$Control/PingNo, $Control/PingYes]
@onready var buttons: Array[Button] = [$Control/ButtonNo, $Control/ButtonYes]
@onready var timer: Timer = $Timer


func enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	buttons[0].grab_focus()

func moved(index: int) -> void:
	for i: int in pings.size():
		pings[i].visible = (i == index) 


func finished(choice: int) -> void:
	for btn: Button in buttons:
		btn.release_focus()
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	G.options = false
	text_box.control.visible = false
	visible = false
	
	timer.start()
	await timer.timeout
	
	G.npc.end_dialog()
	if choice == 1:
		G.npc.on_yes_pressed()
	else:
		G.npc.on_no_pressed()
	G.npc = null


func _on_button_yes_focus_entered() -> void: moved(1)
func _on_button_no_focus_entered() -> void: moved(0)

func _on_button_yes_pressed() -> void: finished(1)
func _on_button_no_pressed() -> void: finished(0)
