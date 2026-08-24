extends CanvasModulate

func _ready() -> void:
	change_darkness()
	G.darkness_changed.connect(change_darkness)

func change_darkness() -> void:
	var darkness: float = Save.options.darknessValue
	if !Save.options.darknessOn:
		darkness /= 2.0

	# 0 = keine Dunkelheit, 255 = komplett schwarz
	var brightness:float = 1.0 - (darkness / 255.0)

	color = Color(brightness, brightness, brightness)
