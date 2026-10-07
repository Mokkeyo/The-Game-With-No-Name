extends Node
class_name Game

@onready var level_manager: LevelManager = $LevelManager
@onready var player_manager: PlayerManager = $PlayerManager
@onready var dialogue_manager: TextboxManager = $DialogueManager
@onready var boss_ui: BossUIManager = $CanvasLayer/BossUIManager
@onready var in_game: InGame = $InGame
@onready var fader: Fader = $Fader
@onready var new_textbox: NewTextBox = $CanvasLayer/textbox
@onready var audio_root: Node = $InGame/HBoxContainer/ViewportContainerP1/SubViewport/AudioRoot
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var pause: PauseMenu = $CanvasLayer/pause

var temp_door: Array[int]

var player_in_airship: Array[bool] = [false, false]


func _ready() -> void:
	setup_systems()
	connect_to_signals()
	
	var level: Node2D = level_manager.load_level(Save.player.levelNumber)
	in_game.add_level(level)

	AudioManager.setup_audio_2d(audio_root)
	
	player_manager.set_player_position(0, level_manager.get_spawn_position())
	fader.fade_in()

func _exit_tree() -> void:
	G.multiplayer_enabled = false

func setup_systems() -> void:
	AI.fader = fader

	var players: Array[Player] = in_game.get_players()
	var timer_label: Label = %TimerLabel
	player_manager.setup(players, in_game.get_pets(), timer_label)
	
	player_manager.clear_footsteps_tilemap()
	
	tree_exited.connect(exit)
	
	dialogue_manager.setup(new_textbox)
	
	boss_ui.setup()
	
	in_game.connect_camera_to_players(players)
	
	in_game.set_viewport_size(false)
	
	fader.visible = true


func exit() -> void:
	AI.fader = null


func connect_to_signals() -> void:
	G.enter_door.connect(change_level)
	G.darkness_changed.connect(_on_darkness_changed)
	G.start_new_dialog.connect(dialogue_manager.start_new_dialog)
	G.player_died.connect(player_manager.on_player_died)
	G.player_died.connect(deactivate_cam)

	G.game_finished.connect(check_for_friend_ach)
	
	G.disable_camera.connect(disable_cameras)
	G.set_camera_offset.connect(_on_set_camera_offset)

	new_textbox.dialog_ended.connect(end_dialog)
	
	G.door_opend.connect(on_door_opend)
	G.boss_begin.connect(boss_ui.show_boss)
	G.boss_finished.connect(boss_ui.hide_boss)
	G.boss_value_changed.connect(boss_ui.set_hp)
	G.boss_label_changed.connect(boss_ui.set_label)
	G.checkpoint_activated.connect(on_checkpoint_activated)

	player_manager.player_respawned.connect(respawn_player)

	player_manager.all_player_died.connect(game_over)
	player_manager.multiplayer_changed.connect(resize_viewport)

#Penis

func check_for_friend_ach() -> void:
	var players: Array[Player] = player_manager.players
	var alive_count: int = 0
	var player_count: int = players.size()
	
	for player: Player in players:
		if player.is_alive:
			alive_count += 1
	
	if alive_count == player_count:
		var ach_comp: AchievmentComponent = $achievmentComponent
		ach_comp.add_achievment()


func disable_cameras(value: bool = true) -> void:
	in_game.disable_cameras(value)


	for i: int in player_manager.player_alive.size():
		if not player_manager.player_alive[i]:
			print("player ", i, " alive ", player_manager.player_alive[i])
			if value:
				deactivate_cam(i)
			else:
				activate_cam(i)


func respawn_player(i: int) -> void:
	var spawn_position: Vector2 = Vector2.ZERO
	
	if player_manager.players[1 - i].remote_transform.remote_path.is_empty():
		push_warning("player_inside airship spawn position changed")
		spawn_position = level_manager.get_spawn_position()
	else:
		spawn_position = player_manager.players[1 - i].global_position
	
	player_manager.respawn_player(i, spawn_position)
	activate_cam(i)


func enable_cameras() -> void:
	in_game.enable_cameras()


func change_level(level_number: int, door_name: String = "") -> void:
	player_manager.clear_footsteps_tilemap()
	AudioManager.stop_all_ambients()
	end_dialog()
	
	Save.player.checkpointActive = false
	
	await fader.fade_out().animation_finished
	enable_cameras()
	
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
	player_manager.players[0].health_component.refill_health(40)
	player_manager.players[1].health_component.refill_health(40)
	animation_player.play("Saving")
	Save.player.levelNumber = level_manager.current_level_number
	for door_nr: int in temp_door:
		if door_nr not in Save.player.door:
			Save.player.door.append(door_nr)
	Save.save_data(Save.active_slot)


func on_door_opend(door_nr: int) -> void:
	temp_door.append(door_nr)


func game_over(player: int) -> void:
	player_manager.clear_footsteps_tilemap()
	get_tree().paused = true
	
	await fader.fade_out().animation_finished
	
	level_manager.reload_level()
	
	var spawn_position: Vector2 = level_manager.get_spawn_position()
	
	player_manager.respawn_player(player, spawn_position)
	
	Save.options.deaths[Save.active_slot] += 1
	Save.save_options()
	fader.fade_in()


func _on_darkness_changed() -> void:
	for light: Light in get_tree().get_nodes_in_group("Light"):
		light.change_darkness()


func end_dialog() -> void:
	await get_tree().create_timer(0.05).timeout
	player_manager.players[0].un_freeze()
	player_manager.players[1].un_freeze()
	dialogue_manager.end_dialog()


func resize_viewport(value: bool) -> void:
	if in_game.cameras[0].enabled == false:
		return

	if value == false:
		player_manager.set_process(false)


		in_game.show_player_bar(1, false)
		in_game.show_player_bar(0, true)

		for i: int in player_manager.player_alive.size():
			player_manager.player_label[i].visible = false
			in_game.show_black_screen(i, false)
	else:
		in_game.show_player_bar(1, false)

	in_game.set_viewport_size(value)


func activate_cam(player: int) -> void:
	in_game.show_black_screen(player, false)
	in_game.show_player_bar(player, true)

func deactivate_cam(player: int) -> void:
	in_game.show_black_screen(player, true)
	in_game.show_player_bar(player, false)

func _on_set_camera_offset(player: int, value: Vector2) -> void:
	in_game.cameras[player].offset = value
