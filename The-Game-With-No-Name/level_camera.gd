extends Camera2D
class_name level_camera
@export var activate_on_ready: bool = false

func _ready() -> void:
	if activate_on_ready:
		activate_camera()


func activate_camera() -> void:
	enabled = true
	G.camera_active.emit()
