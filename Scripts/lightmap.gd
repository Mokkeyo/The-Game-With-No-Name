extends Sprite2D

func _ready() -> void:
	change_darkness()
	G.darkness_changed.connect(change_darkness)

func change_darkness() -> void:
	modulate.a8 = (G.SaveStatInf.darknessValue) if G.SaveStatInf.darknessOn else int(G.SaveStatInf.darknessValue / 2.0)
