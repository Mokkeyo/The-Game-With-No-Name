extends Control
class_name Game

@onready var in_game: InGame = $InGame
@onready var fader: Fader = $Fader
@onready var player_label: Array[Label] = [$Player1Label, $Player2Label]
@onready var respawn_timer: Timer = $respawnTimer
@onready var boss_node: Control = $Boss
@onready var pause: PauseMenu = $pause

var respawnable_obj: Array[EnemyResetComponent]
var level: Node2D = null
var current_level_number: int
var player_spawner: PlayerSpawner

var temp_door: Array[int]
var door_name: String = ""

var player_alive: Array[bool] = [true, false]
var player_in_airship: Array[bool] = [false, false]

var player_size: int

func _ready() -> void:
	player_size = player_alive.size()
	tree_exited.connect(func() -> void: SoundMusic.listeners = [])
	fader.visible = true
	var start_time: float = Time.get_ticks_msec()
	in_game.connect_camera_to_player()
	connect_to_signals()
	setup_level(Save.player.levelNumber)
	initialize_variables()
	set_player_positions()
	on_player_count_changed(-1) 
	G.darkness_changed.connect(_on_darkness_changed)
	print("Ready duration: ", Time.get_ticks_msec() - start_time, "ms")


func setup_level(level_number: int) -> void:
	add_level(level_number)
	get_respawnable_objects()
	player_spawner = level.get_node_or_null("Player_Spawner")
	if player_spawner == null:
		push_warning("Kein Player_Spawner Gefunden")
		return
	
	await get_tree().process_frame
	
	for i: int in in_game.player.size():
		if Save.player.checkpointActive:
			set_player_positions()
		else:
			in_game.player[i].global_position = player_spawner.global_position
			in_game.pet[i].global_position = player_spawner.global_position
			if player_alive[i]:
				print(in_game.player[i].global_position, player_spawner.global_position)
				continue
			
			in_game.player[i].reset_comp.set_stats()
	
	if level_has_camera():
		print("not conneting camera to player")
		in_game.camera[0].enabled = false
		in_game.camera[1].enabled = false
		in_game._set_player_viewport(0, 1024, true)
		in_game._set_player_viewport(1, 0, false)
		
	await get_tree().process_frame
	fader.fade_in()
	set_player_position_to(door_name)


func add_level(level_number: int) -> void:
	for player: Player in in_game.player:
		player.reset_comp.set_stats()
	var currentLevel: PackedScene = load("res://Level/level_%d.tscn" % level_number)
	current_level_number = level_number
	level = currentLevel.instantiate()
	in_game.add_level(level)
	player_in_airship.fill(false)


func get_respawnable_objects() -> void:
	respawnable_obj = []
	for node: EnemyResetComponent in get_tree().get_nodes_in_group("respawnable"):
		respawnable_obj.append(node)


func initialize_variables() -> void:
	var light_map: ColorRect = $InGame/lightmap
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().paused = false
	light_map.visible = true
	fader.visible = true


func connect_to_signals() -> void:
	G.enter_door.connect(change_level)
	G.start_dialog.connect(check_for_dialog)
	G.player_died.connect(on_player_count_changed)
	G.door_opend.connect(on_door_opend)
	G.boss_begin.connect(show_boss_hp)
	G.boss_finished.connect(hide_boss_hp)
	G.boss_value_changed.connect(change_boss_hp)
	G.boss_label_changed.connect(change_boss_label)
	G.checkpoint_activated.connect(on_checkpoint_activated)

func restart_level(player: int) -> void:
	initialize_variables()
	respawn_timer.stop()
	for obj: EnemyResetComponent in respawnable_obj:
		var parent: Node2D = obj.get_parent()
		 
		if not parent.is_in_group("Player"):
			obj.reset_stats()
			continue
		
		if parent. is_in_group("Player_" + str(player)):
			obj.reset_stats()
		
	player_alive[player] = true
	set_player_positions()
	await fader.fade_in().animation_finished
	pause.can_pause = true


func set_player_position_to(d_name: String) -> void:
	if not d_name == "":
		var door: Node2D = level.find_child(d_name)
		if not door:
			push_warning(d_name+ " not found")
			return
		
		for i: int in in_game.player.size():
			if player_alive[i]:
				in_game.player[i].reset_comp.reset_stats()
				in_game.player[i].global_position = door.global_position
				in_game.pet[i].global_position = door.global_position
			else:
				in_game.player[i].reset_comp.set_stats()
			door_name = ""

#Penis

func on_checkpoint_activated() -> void:
	for door_nr: int in temp_door:
		if door_nr not in Save.player.door:
			Save.player.door.append(door_nr)
	Save.save_data()


func on_door_opend(door_nr: int) -> void:
	temp_door.append(door_nr)


func set_player_positions() -> void:
	for i: int in player_size:
		if player_alive[i] and in_game.player[i]:
			if Save.player.checkpointActive:
				in_game.player[i].reset_comp.reset_stats()
				in_game.player[i].global_position = Save.player.checkpointPosition 
			else:
				in_game.player[i].reset_comp.reset_stats()
				in_game.player[i].global_position = player_spawner.global_position


func game_over(player: int) -> void:
	pause.can_pause = false
	get_tree().paused = true
	await fader.fade_out().animation_finished
	restart_level(player)


func change_level(level_number: int, d_name: String) -> void:
	door_name = d_name
	var start_time: float = Time.get_ticks_msec()
	await fader.fade_out().animation_finished
	
#	get_tree().paused = false
	
	if not level_number == current_level_number:
		in_game.viewport[0].remove_child(level)
		level.queue_free()
		Save.player.levelNumber = level_number
		Save.player.checkpointActive = false
		Save.player.door.clear()
		SoundComp.tilemaps = []
		temp_door.clear()
		setup_level(level_number)
	else:
		print("same level setting up")
		set_player_position_to(d_name)
#		await get_tree().process_frame
		fader.fade_in()
	
	Save.save_data()
	print("Reload duration: ", Time.get_ticks_msec() - start_time, "ms")



func on_player_count_changed(player: int) -> void:
	if player > -1:
		player_alive[player] = not player_alive[player]
		if not player_alive[player]:
			Save.options.deaths[Save.active_slot] += 1
			Save.save_options()
		
		
	var both_death: bool = not player_alive[0] and not player_alive[1]
	
	if both_death:
		game_over(player)
		return
	if player > -1:
		respawn_timer.start()
	if not level_has_camera():
		in_game.set_viewport_size(player_alive)


func level_has_camera() -> bool:
	if current_level_number == 5:
		return true
	
	return false


func _unhandled_input(_event: InputEvent) -> void:
	for i: int in player_size:
		if Input.is_action_just_pressed("player%d_spawn" % int(i + 1)) and not player_alive[i]:
			var player_position: Vector2 = in_game.player[1 - i].global_position
			player_alive[i] = true
			player_label[i].visible = false
			var player: Player = in_game.player[i]
			player.reset_comp.reset_stats()
			player.global_position = player_position
			in_game.pet[i].global_position = player_position
			
			if player_spawner.airship_spawner:
				player_spawner.airship_spawner.set_airship_respawn_position(i, player_position)
				player.enter_airship(player_spawner.airship_spawner.airship[i])
			
			set_process_unhandled_input(false)
			if not level_has_camera():
				in_game.set_viewport_size(player_alive)
			break


func check_for_dialog(blackBox: bool, options: bool, speaker: String, dialog: Array, npc: Npc) -> void:
	var text_box: TextBox = $TextBox
	text_box.speaker_name = speaker
	text_box.dialog = dialog
	text_box.options = options
	text_box.black_box = blackBox
	text_box.npc = npc
	text_box.start()


func show_boss_hp(boss_label: String, boss_hp: float) -> void:
	change_boss_hp(boss_hp)
	change_boss_label(boss_label)
	boss_node.visible = true


func hide_boss_hp() -> void: 
	boss_node.visible = false

func change_boss_hp(boss_hp: float) -> void: 
	var boss_hp_bar: HealthBar = $Boss/BossHP
	boss_hp_bar.set_percent_value_int(boss_hp)

func change_boss_label(label: String) -> void: 
	var boss_label: Label = $Boss/Label
	boss_label.text = label

func _on_darkness_changed() -> void:
	for light: Light in get_tree().get_nodes_in_group("Light"):
		light.change_darkness()

func _on_respawnTimer_timeout() -> void:
	for i: int in player_size:
		if not player_alive[i]:
			player_label[i].visible = true
	
	var animation_player: AnimationPlayer = $AnimationPlayer
	animation_player.play("PlayerCanRespawn")
	set_process_unhandled_input(true)
