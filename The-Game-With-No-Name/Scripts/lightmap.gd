extends ColorRect

func _ready() -> void:
	visible = true
	change_darkness()
	G.darkness_changed.connect(change_darkness)

func change_darkness() -> void:
	modulate.a8 = (Save.options.darknessValue) if Save.options.darknessOn else int(Save.options.darknessValue / 2.0)
