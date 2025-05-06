extends Node

signal darkness_changed
signal checkpoint_activated
signal fullscreen_changed
signal enter_door
signal achievment_collected
signal start_dialog
signal player_died

signal health_value_changed
signal mana_value_changed

signal boss_begin
signal boss_finished
signal boss_value_changed
signal boss_label_changed

var SaveStatInf: saveStatInf  = saveStatInf.new()
var SaveStat: saveStat = saveStat.new()
var SavedInputMap: savedInputmap = savedInputmap.new()

#turn the .tres to .res befor export do decrypt the saveFile
const save_file_name: Array[String] = ["/options.tres", 
									"/savegame_1.tres", "/savegame_2.tres", "/savegame_3.tres", "/savegame_4.tres",
									"/controlls.tres"]

const save_path: String = "res://GameWithNoName_saveFiles"
var path: int = 0 #Used to check which save file to use
var arena: int = 1 #Used for the Battle Mode to know which Arena to Load

var speaker: String
var dialog: Array

var tempDoor: Array [int] = []

#variables for the Boss
var bossLabel: String = ""
var bossHp: float = 0
var maxBossHp: float = 0

#var load_level: bool = false

#Dialog Variables
var npc: Npc
var black_box: bool = false
var options: bool = false

#battle Mode Variables
var sword: bool = true
var wand: bool = true
var jump: bool = true
var battlePlayerHeal: Array[int] = [20, 100, 100]
var battle_hitpoints: int = 10
var battle_time: int = 0
var last_number: int = 0
var battleReady: Array[bool] = [false, false]
var battle_damage: bool = false
var battle_mode: bool = false

var next_level_door: String = ""
var player_get_in: bool = false

var airshipHeal: Array[float] = [100.0, 100.0]
var playerAlive: Array[bool] = [true, false]
var playerInAirship: Array[bool] = [false, false]

var max_text: int = 0


func _ready() -> void:
	print("scene was reloaded")
	process_mode = Node.PROCESS_MODE_ALWAYS
	fullscreen_changed.connect(change_resolution)
	
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	for i: int in range(D.allText.size()):
		if typeof(D.dialogue[D.allText[i]][D.dialog]) == TYPE_ARRAY:
			var temp: Array = D.dialogue[D.allText[i]][D.dialog]
			max_text += temp.size()
		else:
			max_text += 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f11"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if SaveStatInf.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		SaveStatInf.fullscreen = not SaveStatInf.fullscreen
		
		if not SaveStatInf.fullscreen:
			change_resolution()
		
		save_options()
		emit_signal("fullscreen_changed")

	if SaveStatInf.textboxCount == max_text and not SaveStatInf.achievments.has("Chatter"):
		SaveStatInf.achievments.append("Chatter")
		save_options()

func save_inputs() -> void:
	ResourceSaver.save(SavedInputMap, save_path + save_file_name[5])

func load_inputs() -> void:
	if ResourceLoader.exists(save_path + save_file_name[5]):
		SavedInputMap = ResourceLoader.load(save_path + save_file_name[5]).duplicate(true)
		var playerInput: Array[String] = ["_up", "_down", "_left", "_right", "_jump", "_attack", "_wand", "_interact", "_spawn"]
		for playerIndex: int in range(playerAlive.size()):
			for inputIndex: int in range(playerInput.size()):
				var input_name: String = str("player", playerIndex + 1, playerInput[inputIndex])
				add_inputs(input_name)
				add_inputs(str("C-", input_name))
	else:
		save_inputs()


func add_inputs(input: String) -> void:
	var action_name: String = str(input)
	var ev: InputEvent = SavedInputMap.inputMap[action_name]
	
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, ev)

func save_data() -> void:
	ResourceSaver.save(SaveStat, save_path + save_file_name[path])

func load_data() -> void:
	if ResourceLoader.exists(save_path + save_file_name[path]):
		SaveStat = ResourceLoader.load(save_path + save_file_name[path]).duplicate(true)
	else:
		save_data()

func save_options() -> void:
	ResourceSaver.save(SaveStatInf, save_path + save_file_name[0])

func load_options() -> void:
	if ResourceLoader.exists(save_path + save_file_name[0]):
		SaveStatInf = ResourceLoader.load(save_path + save_file_name[0]).duplicate(true)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveStatInf.vsync else DisplayServer.VSYNC_DISABLED)
		var maxfps: MaxFpsButton = MaxFpsButton.new()
		Engine.max_fps = maxfps.Fps.values()[G.SaveStatInf.maxFps]
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if SaveStatInf.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		change_resolution()
	else:
		save_options()


func center_window() -> void:
	var center_screen: Vector2i = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var window_size: Vector2i = get_window().get_size_with_decorations()
	get_window().set_position(center_screen - window_size/2)


func change_resolution() -> void:
	if not G.SaveStatInf.fullscreen:
		get_window().set_size(SaveStatInf.resolution)
		center_window()

func start_new_game() -> void:
	for i: int in range(SaveStat.kristallCollected.size()):
		SaveStat.kristallCollected[i] = false
		
		if i < 2:
			SaveStat.playerHp[i] = 100
			SaveStat.playerMana[i] = 99
		
		if i < 3:
			SaveStat.finished[i] = false
	
	SaveStat.levelNumber = 1
	SaveStat.checkpointActive = false
	SaveStat.checkpointPosition = Vector2(0, 0)
	SaveStat.kristallCount = 0
	tempDoor.clear()
	SaveStat.door.clear() 
	playerAlive[1] = false
	save_data()

func delete_data() -> void:
	DirAccess.remove_absolute(save_path + save_file_name[path])
	var temp_path: int = path - 1
	SaveStatInf.deaths[temp_path] = 0
	SaveStatInf.playerName[temp_path] = ""
	save_options()
