extends Node

signal darkness_changed
signal checkpoint_activated
signal fullscreen_changed
signal enter_door(level_number: int, door_name: String)
signal achievment_collected
signal start_dialog
signal player_died
signal door_opend
signal camera_active
signal health_value_changed
signal mana_value_changed

signal boss_begin(label: String, hp: float)
signal boss_finished
signal boss_value_changed(hp: float)
signal boss_label_changed(label: String)

var listeners: Array[Node2D] = []
var level_viewport: SubViewport


enum DamageType {
	NORMAL,
	LAVA,
	DOT,
	ENVIRONMENT
}

var arena: int = 1 #Used for the Battle Mode to know which Arena to Load

#battle Mode Variables
var sword: bool = true
var wand: bool = true
var jump: bool = true
var battle_player_heal: Array[int] = [20, 100, 100]
var battle_hitpoints: int = 10
var battle_time: int = 0
var last_number: int = 0
var battle_ready: Array[bool] = [false, false]
var battle_damage: bool = false
var battle_mode: bool = false

var max_text: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	fullscreen_changed.connect(change_resolution)
	calculate_max_text()




func calculate_max_text() -> void:
	max_text = 0
	for i: int in range(D.allText.size()):
		if typeof(D.dialogue[D.allText[i]][D.dialog]) == TYPE_ARRAY:
			var temp: Array = D.dialogue[D.allText[i]][D.dialog]
			max_text += temp.size()
		else:
			max_text += 1


func apply_display_settings() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if Save.options.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)
	
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if Save.options.vsync else DisplayServer.VSYNC_DISABLED
	)
	
	if Engine.has_singleton("MaxFpsButton"):
		var maxfps: MaxFpsButton = MaxFpsButton.new()
		Engine.max_fps = maxfps.Fps.values()[clamp(Save.options.maxFps, 0, maxfps.Fps.size() - 1)]
	
	if not Save.options.fullscreen:
		get_window().set_size(Save.options.resolution)
		center_window()


func center_window() -> void:
	var center_screen: Vector2i = DisplayServer.screen_get_position() + Vector2i(DisplayServer.screen_get_size()/2.0)
	var window_size: Vector2i = get_window().get_size_with_decorations()
	get_window().set_position(center_screen - Vector2i(window_size/2.0))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f11"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if Save.options.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		Save.options.fullscreen = not Save.options.fullscreen
		
		if not Save.options.fullscreen:
			apply_display_settings()
		Save.save_options()
		fullscreen_changed.emit()


func check_if_chatter_unlocked() -> void:
	if Save.options.textboxCount == max_text and not Save.options.achievments.has("Chatter"):
		Save.options.achievments.append("Chatter")
		Save.save_options()


func change_resolution() -> void:
	if not Save.options.fullscreen:
		get_window().set_size(Save.options.resolution)
		center_window()
