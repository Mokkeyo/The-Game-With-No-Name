extends Control
class_name Game

@onready var level_manager: LevelManager = $LevelManager
@onready var player_manager: PlayerManager = $PlayerManager
@onready var dialogue_manager: TextboxManager = $DialogueManager
@onready var boss_ui: BossUIManager = $BossUIManager
@onready var in_game: InGame = $InGame
@onready var fader: Fader = $Fader
@onready var textbox: TextBox = $TextBox
@onready var new_textbox: NewTextBox = $textbox

@onready var pause: PauseMenu = $pause

var temp_door: Array[int]

var player_in_airship: Array[bool] = [false, false]


func _ready() -> void:
	setup_systems()
	connect_to_signals()
	
	var level: Node2D = level_manager.load_level(Save.player.levelNumber)
	in_game.add_level(level)
	
	player_manager.set_player_position(0, level_manager.get_spawn_position())
	fader.fade_in()


func setup_systems() -> void:
#	AI.fader = fader
	
	var players: Array[Player] = in_game.get_players()
	
	player_manager.setup(players, in_game.get_pets())
	
	player_manager.clear_footsteps_tilemap()
	
	tree_exited.connect(exit)
	
	dialogue_manager.setup(textbox, new_textbox)
	
	boss_ui.setup()
	
	in_game.connect_camera_to_players(players)
	
	in_game.set_viewport_size(player_manager.get_alive_states())
	
	fader.visible = true


func exit() -> void:
#	AI.fader = null
	SoundMusic.listeners = []


func connect_to_signals() -> void:
	G.enter_door.connect(change_level)
	G.darkness_changed.connect(_on_darkness_changed)
#	G.start_dialog.connect(dialogue_manager.start_dialog)
	G.start_new_dialog.connect(dialogue_manager.start_new_dialog)
	G.player_died.connect(player_manager.on_player_died)
	
	G.camera_active.connect(disable_cameras)
	
	new_textbox.dialog_ended.connect(end_dialog)
	
	G.door_opend.connect(on_door_opend)
	G.boss_begin.connect(boss_ui.show_boss)
	G.boss_finished.connect(boss_ui.hide_boss)
	G.boss_value_changed.connect(boss_ui.set_hp)
	G.boss_label_changed.connect(boss_ui.set_label)
	G.checkpoint_activated.connect(on_checkpoint_activated)

	player_manager.player_respawned.connect(respawn_player)
	player_manager.all_player_died.connect(game_over)
	player_manager.player_count_changed.connect(resize_viewport.bind(player_manager.player_alive))

#Penis


func disable_cameras() -> void:
	in_game.disable_cameras()

func respawn_player(i: int) -> void:
	var spawn_position: Vector2 = Vector2.ZERO
	
	if player_manager.players[1 - i].remote_transform.remote_path.is_empty():
		push_warning("player_inside airship spawn position changed")
		spawn_position = level_manager.get_spawn_position()
	else:
		spawn_position = player_manager.players[1 - i].global_position
	
	player_manager.respawn_player(i, spawn_position)


func enable_cameras() -> void:
	in_game.enable_cameras()


func resize_viewport(value: Array[bool]) -> void:
	if in_game.cameras[0].enabled == false:
		return
	
	in_game.set_viewport_size(value)


func change_level(level_number: int, door_name: String = "") -> void:
	player_manager.clear_footsteps_tilemap()
	end_dialog()
	
	Save.player.checkpointActive = false
	
	await fader.fade_out().animation_finished
	enable_cameras()
	resize_viewport(player_manager.player_alive)
	
	var level: Node2D = null
	
	if not level_manager.is_same_level(level_number):
		level = await level_manager.transition_new_level(level_number)
		in_game.add_level(level)
	
	await get_tree().process_frame
	
	var d_position: Vector2 = level_manager.get_door_position(door_name)
	
	for player: int in player_manager.players.size():
		if not player_manager.player_alive[player] == true:
			continue
		
		player_manager.set_player_position(player, d_position)
	
	fader.fade_in()


func on_checkpoint_activated() -> void:
	Save.player.levelNumber = level_manager.current_level_number
	for door_nr: int in temp_door:
		if door_nr not in Save.player.door:
			Save.player.door.append(door_nr)
	Save.save_data()


func on_door_opend(door_nr: int) -> void:
	temp_door.append(door_nr)


func game_over(player: int) -> void:
	player_manager.clear_footsteps_tilemap()
	get_tree().paused = true
	
	await fader.fade_out().animation_finished
	
	level_manager.reload_level()
	
	var spawn_position: Vector2 = level_manager.get_spawn_position()
	
	player_manager.respawn_player(player, spawn_position)
	
	fader.fade_in()


func _on_darkness_changed() -> void:
	for light: Light in get_tree().get_nodes_in_group("Light"):
		light.change_darkness()


func end_dialog() -> void:
	await get_tree().create_timer(0.05).timeout
	player_manager.players[0].freeze = false
	dialogue_manager.end_dialog()
