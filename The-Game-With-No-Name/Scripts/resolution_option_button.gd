extends OptionButton
class_name ResolutionButton

var Resolution: Dictionary = {"1024 x 576" : Vector2i(1024,576),
								"1280 x 720" : Vector2i(1280, 720),
								"1360 x 768" : Vector2i(1360, 768),
								"1440 x 810" : Vector2i(1440, 810),
								"1600 x 900" : Vector2i(1600, 900),
								"1920 x 1080" : Vector2i(1920, 1080)
	 }

func _ready() -> void:
	start()


func start() -> void:
	for r: String in Resolution:
		add_item(r)
	select(G.save_stat_inf.resolutionIndex)


func _on_item_selected(index: int) -> void:
	var value: Vector2i = Resolution.values()[index]
	G.save_stat_inf.resolution = value
	G.save_stat_inf.resolutionIndex = index
	G.save_options()
	
	if not G.save_stat_inf.fullscreen:
		get_window().set_size(value)
		G.center_window()
