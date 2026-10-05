extends Camera2D
class_name level_camera
@export var activate_on_ready: bool = false

func _ready() -> void:
	if activate_on_ready:
		activate_camera()

func _exit_tree() -> void:
	disable_camera()

func activate_camera() -> void:
	enabled = true
	G.disable_camera.emit(false)

func disable_camera() -> void:
	enabled = false
	G.disable_camera.emit(true)