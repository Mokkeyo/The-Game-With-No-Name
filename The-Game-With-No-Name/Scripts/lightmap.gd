extends ColorRect

func _ready() -> void:
	visible = true
	change_darkness()
	G.darkness_changed.connect(change_darkness)

func change_darkness() -> void:
	modulate.a8 = (G.save_stat_inf.darknessValue) if G.save_stat_inf.darknessOn else int(G.save_stat_inf.darknessValue / 2.0)
