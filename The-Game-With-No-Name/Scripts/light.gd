extends PointLight2D
class_name Light

func _ready() -> void:
#	visible = true
	change_darkness()

func change_darkness() -> void:
	energy = (Save.options.darknessValue / 100.0) if Save.options.darknessOn else (Save.options.darknessValue / 200.0)
