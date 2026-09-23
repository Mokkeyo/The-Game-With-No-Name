extends Control
class_name AssignControllerMenu

signal exited

var player: int = 0
var input_device: int = 0
@onready var conformation: Control = %Conformation
@onready var yes_button: Menu_Button = %YesButton
@onready var no_button: Menu_Button = %NoButton

func _ready() -> void:
    visible = false
    conformation.visible = false
    yes_button.pressed.connect(yes_pressed)
    no_button.pressed.connect(no_pressed)
    set_process_unhandled_input(false)


func enter(p: int) -> void:
    player = p
    show()
    set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
    print("unhanded input")
    if event.is_pressed() and event is InputEventJoypadButton:
        input_device = event.device
        if device_taken():
            get_device_conformation()
        else:
            handle_device_assignment()

    if not Input.is_action_just_pressed("escape"):
        return
	
    exit()


func device_taken() -> bool:
    var other_player: int = 0 if player == 1 else 1
    var other_player_input: int = InputSerializer.get_device_from_player(Save.inputs, other_player)

    if other_player_input == input_device:
        return true
	
    return false


func get_device_conformation() -> void:
    yes_button.grab_focus()
    conformation.visible = true


func handle_device_assignment() -> void:
    if input_device < 0:
        return

    InputSerializer.change_device_for_player(Save.inputs, player, input_device)
    InputSerializer.apply_inputmap_from_dict(Save.inputs)
    Save.save_inputs()
    exit()


func no_pressed() -> void:
    exit()


func yes_pressed() -> void:
    handle_device_assignment()
    exit()


func exit() -> void:
    hide()
    conformation.hide()
    set_process_unhandled_input(false)
    input_device = -1
    exited.emit()