extends PointLight2D
class_name Light

func _ready() -> void:
#	visible = true
	change_darkness()

func change_darkness() -> void:
	energy = (G.save_stat_inf.darknessValue / 100.0) if G.save_stat_inf.darknessOn else (G.save_stat_inf.darknessValue / 200.0)
