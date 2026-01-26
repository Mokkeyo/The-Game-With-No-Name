extends OptionButton
class_name MaxFpsButton

var Fps: Dictionary = {"0":0,
						"60":60,
						"90":90,
						"120":120,
						"150":150,
						"180":180,
						"210":210,
						"240":240
}

func _ready() -> void:
	for f: String in Fps:
		add_item(f)
	
	start()


func start() -> void:
	var value: int = G.save_stat_inf.maxFps
	select(value)
	Engine.max_fps = Fps.values()[G.save_stat_inf.maxFps]


func _on_item_selected(index: int) -> void:
	Engine.max_fps = Fps.values()[index]
	G.save_stat_inf.maxFps = index
	G.save_options()
