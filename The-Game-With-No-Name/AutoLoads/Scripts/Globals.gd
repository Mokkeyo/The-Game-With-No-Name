extends Node

signal darkness_changed
signal checkpoint_activated
signal fullscreen_changed
signal enter_door
signal achievment_collected
signal start_dialog
signal player_died
signal door_opend

signal health_value_changed
signal mana_value_changed

signal boss_begin
signal boss_finished
signal boss_value_changed
signal boss_label_changed

#turn the .tres to .res befor export do decrypt the saveFile
const SAVE_FILES: Dictionary = {
	"options": "/options.tres", 
	"slots": ["/savegame_1.tres", "/savegame_2.tres", "/savegame_3.tres", "/savegame_4.tres"],
	"controls": "/controlls.tres"}

const SAVE_PATH: String = "res://GameWithNoName_saveFiles"

var save_stat_inf: SaveStatInf  = SaveStatInf.new()
var save_stat: SaveStat = SaveStat.new()
var saved_input_map: SavedInputmap = SavedInputmap.new()

var active_slot: int = 0 #Used to check which save file to use
var arena: int = 1 #Used for the Battle Mode to know which Arena to Load

#var tempDoor: Array [int] = []

#Dialog Variables
#var npc: Npc

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

#var next_level_door: String = ""
#var player_get_in: bool = false

#var airship_heal: Array[float] = [100.0, 100.0]
#var player_alive: Array[bool] = [true, false]
#var player_in_airship: Array[bool] = [false, false]

var max_text: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ensure_save_path()
	fullscreen_changed.connect(change_resolution)
	calculate_max_text()


func ensure_save_path() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)


func load_or_save(default_res: Resource, file_path: String) -> Resource:
	if ResourceLoader.exists(file_path):
		var loaded: Resource = ResourceLoader.load(file_path)
		if loaded:
			return loaded.duplicate(true)
	
	ResourceSaver.save(default_res, file_path)
	return default_res


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
		DisplayServer.WINDOW_MODE_FULLSCREEN if save_stat_inf.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)
	
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if save_stat_inf.vsync else DisplayServer.VSYNC_DISABLED
	)
	
	if Engine.has_singleton("MaxFpsButton"):
		var maxfps: MaxFpsButton = MaxFpsButton.new()
		Engine.max_fps = maxfps.Fps.values()[clamp(save_stat_inf.maxFps, 0, maxfps.Fps.size() - 1)]
	
	if not save_stat_inf.fullscreen:
		get_window().set_size(save_stat_inf.resolution)
		center_window()


func center_window() -> void:
	var center_screen: Vector2i = DisplayServer.screen_get_position() + Vector2i(DisplayServer.screen_get_size()/2.0)
	var window_size: Vector2i = get_window().get_size_with_decorations()
	get_window().set_position(center_screen - Vector2i(window_size/2.0))



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f11"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if save_stat_inf.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		save_stat_inf.fullscreen = not save_stat_inf.fullscreen
		
		if not save_stat_inf.fullscreen:
			apply_display_settings()
		save_options()
		emit_signal("fullscreen_changed")


func check_if_chatter_unlocked() -> void:
	if save_stat_inf.textboxCount == max_text and not save_stat_inf.achievments.has("Chatter"):
		save_stat_inf.achievments.append("Chatter")
		save_options()


func save_inputs() -> void:
	ensure_save_path()
	var file_path: String = SAVE_PATH + SAVE_FILES["controls"]
	ResourceSaver.save(saved_input_map, file_path)


func load_inputs() -> void:
	var file_path: String = SAVE_PATH + SAVE_FILES["controls"]
	if not ResourceLoader.exists(file_path):
		save_inputs()
		return
	
	var loaded: Resource = ResourceLoader.load(file_path)
	
	if not loaded:
		return
		
	saved_input_map = loaded.duplicate(true)
	var playerInput: Array[String] = ["_up", "_down", "_left", "_right", "_jump", "_attack", "_wand", "_interact", "_spawn"]
	for playerIndex: int in range(2):
		for inputIndex: int in playerInput.size():
			var input_name: String = str("player", playerIndex + 1, playerInput[inputIndex])
			InputMap.action_erase_events(input_name)
			add_inputs(input_name)


func add_inputs(action_name: String) -> void:
	if not saved_input_map.inputMap.has(action_name):
		push_warning("input "+ action_name + " not found in SavedInputMap")
		return
	
	var input_events: Array = saved_input_map.inputMap[action_name]
	
	for ev: InputEvent in input_events:
		InputMap.action_add_event(action_name, ev)


func save_data() -> void:
	ensure_save_path()
	var file_path: String = SAVE_PATH + SAVE_FILES["slots"][clamp(active_slot, 0, SAVE_FILES["slots"].size() -1)]
	ResourceSaver.save(save_stat, file_path)


func load_data() -> void:
	var file_path: String = SAVE_PATH + SAVE_FILES["slots"][clamp(active_slot, 0, SAVE_FILES["slots"].size() -1)]
	save_stat = load_or_save(save_stat, file_path)

func save_options() -> void:
	ensure_save_path()
	var file_path: String = SAVE_PATH + SAVE_FILES["options"]
	ResourceSaver.save(save_stat_inf, file_path)

func load_options() -> void:
	var file_path: String = SAVE_PATH + SAVE_FILES["options"]
	save_stat_inf = load_or_save(save_stat, file_path)
	apply_display_settings()

func change_resolution() -> void:
	if not save_stat_inf.fullscreen:
		get_window().set_size(save_stat_inf.resolution)
		center_window()

func start_new_game() -> void:
	for i: int in save_stat.kristallCollected.size():
		save_stat.kristallCollected[i] = false
		
		if i < save_stat.playerHp.size():
			save_stat.playerHp[i] = 100
		if i < save_stat.playerMana.size():
			save_stat.playerMana[i] = 99
		if i < save_stat.finished.size():
			save_stat.finished[i] = false
	
	save_stat.levelNumber = 1
	save_stat.checkpointActive = false
	save_stat.checkpointPosition = Vector2(0, 0)
	save_stat.kristallCount = 0
	if save_stat.door:
		save_stat.door.clear() 
	save_data()

func delete_data() -> void:
	var file_path: String = SAVE_PATH + SAVE_FILES["slots"][clamp(active_slot, 0, SAVE_FILES["slots"].size() -1)]
	if FileAccess.file_exists(file_path):
		var err: Error = DirAccess.remove_absolute(file_path)
		if not err == OK:
			push_error("Could not delete save files %s" % file_path)
	
	var temp_index: int = active_slot
	
	if temp_index < 0:
		return
	
	if temp_index < save_stat_inf.deaths.size():
		save_stat_inf.deaths[temp_index] = 0
	if temp_index < save_stat_inf.playerName.size():
		save_stat_inf.playerName[temp_index] = ""
	save_options()
