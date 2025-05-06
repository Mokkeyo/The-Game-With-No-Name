extends PointLight2D

func _ready() -> void:
	visible = true
	G.darkness_changed.connect(change_darkness)
	change_darkness()

func change_darkness() -> void:
	energy = (G.SaveStatInf.darknessValue / 100.0) if G.SaveStatInf.darknessOn else (G.SaveStatInf.darknessValue / 200.0)
