extends TextureRect
class_name progressBar

@onready var progress: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	progress.value = 100


func set_percent_value_int(value: float) -> float:
	var tween: Tween = create_tween()
	tween.tween_property(progress,"value",value, 0.2)
	return value

func set_value_int(value: float) -> float:
	progress.value = value
	return value
