extends PointLight2D
class_name Light

func _ready() -> void:
	visible = true
	change_darkness()

func change_darkness() -> void:
	energy = (G.SaveStatInf.darknessValue / 100.0) if G.SaveStatInf.darknessOn else (G.SaveStatInf.darknessValue / 200.0)
