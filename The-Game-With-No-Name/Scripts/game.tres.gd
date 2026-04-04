extends Control
class_name Game

@onready var in_game: InGame = $InGame
@onready var fader: Fader = $Fader
@onready var level_manager: LevelManager = $LevelManager
@onready var player_manager: PlayerManager = $PlayerManager

var current_level_number: int

var temp_door: Array[int] = []
var player_alive: Array[bool] = [true, false]

var player_in_airship: Array[bool] = [false, false]

var player_size: int

func _ready() -> void:
	player_size = player_alive.size()
	
	fader.visible = true
	var start_time: float = Time.get_ticks_msec()
	connect_to_signals()
	level_manager.setup_level()
	initialize_variables()
	player_manager.set_player_positions()
	player_manager.on_player_count_changed(-1) 
	G.darkness_changed.connect(_on_darkness_changed)
	print("Ready duration: ", Time.get_ticks_msec() - start_time, "ms")


func initialize_variables() -> void:
	var light_map: ColorRect = $InGame/lightmap
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().paused = false
	light_map.visible = true


func connect_to_signals() -> void:
	G.enter_door.connect(level_manager.change_level)
	G.start_dialog.connect(check_for_dialog)
	G.door_opend.connect(on_door_opend)
	G.checkpoint_activated.connect(on_checkpoint_activated)


func on_checkpoint_activated() -> void:
	for door_nr: int in temp_door:
		if door_nr not in G.save_stat.door:
			G.save_stat.door.append(door_nr)
	G.save_data()


func on_door_opend(door_nr: int) -> void:
	temp_door.append(door_nr)


func on_enter_kristall() -> void:
	fader.kristall_text = current_level_number
	level_manager.change_level()


func check_for_dialog(blackBox: bool, options: bool, speaker: String, dialog: Array, npc: Npc) -> void:
	var text_box: TextBox = $TextBox
	text_box.speaker_name = speaker
	text_box.dialog = dialog
	text_box.options = options
	text_box.black_box = blackBox
	text_box.npc = npc
	text_box.start()


func _on_darkness_changed() -> void:
	for light: Light in get_tree().get_nodes_in_group("Light"):
		light.change_darkness()
