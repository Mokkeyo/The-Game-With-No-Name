extends Control
class_name ContollerDisconnectMenu

@export var pause_menu: PauseMenu = null
@onready var player_label: Label = %PlayerLabel

var is_already_pausing: bool
var is_disconnected: bool = false

func _ready() -> void:
    hide()
    Input.joy_connection_changed.connect(_on_controller_disconnected)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("esc"):
        exit()

func _on_controller_disconnected(device: int, connected: bool) -> void:
    if connected:
        if is_disconnected:
            exit()
        return

    if pause_menu.is_pausing:
        is_already_pausing = true
        pause_menu.is_pausing = false
    else:
        get_tree().paused = true

    is_disconnected = true
    set_process_unhandled_input(true)

    for i: int in 1:
        if device == InputSerializer.get_device_from_player(Save.inputs, i):
            player_label.text = str("Controller from Player ", i + 1 ," Disconnected") 
            show()


func exit() -> void:
    hide()

    is_disconnected = false
    set_process_unhandled_input(false)

    await get_tree().process_frame

    if is_already_pausing:
      pause_menu.is_pausing = true
    else:
        get_tree().paused = false