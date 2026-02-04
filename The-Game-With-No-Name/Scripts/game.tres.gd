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

var player_alive: Array[bool] = [true, false]

enum PlayerState {ALIVE, DEAD, RESPAWNING}

var playe_state: Array[Game.PlayerState] = [
	PlayerState.ALIVE,
	PlayerState.DEAD
]

var player_in_airship: Array[bool] = [false, false]
var next_level_door: String

var player_size: int

func _ready() -> void:
	player_size = player_alive.size()
	
	fader.visible = true
	var start_time: float = Time.get_ticks_msec()
	connect_to_signals()
	setup_level()
	initialize_variables()
	check_for_door()
	set_player_positions()
	on_player_count_changed(-1) 
	G.darkness_changed.connect(_on_darkness_changed)
	print("Ready duration: ", Time.get_ticks_msec() - start_time, "ms")


func setup_level() -> void:
	add_level()
	get_respawnable_objects()
	player_spawner = level.get_node_or_null("Player_Spawner")
	if not player_spawner:
		push_warning("Kein Player_Spawner Gefunden")
		return
	
	player_spawner.spawn_player(player_alive)
	in_game.player = player_spawner.player.duplicate()
	in_game.connet_camera_to_player()
	fader.fade_in()


func add_level() -> void:
	var currentLevel: PackedScene = load("res://Level/level_%d.tscn" % G.save_stat.levelNumber)
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
	G.enter_door.connect(reload)
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


func on_checkpoint_activated() -> void:
	for door_nr: int in temp_door:
		if door_nr not in G.save_stat.door:
			G.save_stat.door.append(door_nr)
	G.save_data()


func on_door_opend(door_nr: int) -> void:
	temp_door.append(door_nr)


func set_player_positions() -> void:
	for i: int in player_size:
		if player_alive[i] and in_game.player[i]:
			in_game.player[i].global_position = G.save_stat.checkpointPosition 


func game_over(player: int) -> void:
	pause.can_pause = false
	get_tree().paused = true
	await fader.fade_out().animation_finished
	restart_level(player)


func reload() -> void:
	G.save_stat.door.clear()
	temp_door.clear()
	var start_time: float = Time.get_ticks_msec()
	await fader.fade_out().animation_finished
	
	get_tree().paused = false
	
	in_game.viewport[0].remove_child(level)
	setup_level()
	
	print("Reload duration: ", Time.get_ticks_msec() - start_time, "ms")

func check_for_door() -> void:
	next_level_door = ""


func on_enter_kristall() -> void:
	fader.kristall_text = current_level_number
	reload()


func on_player_count_changed(player: int) -> void:
	if player > -1:
		player_alive[player] = not player_alive[player]
		if not player_alive[player]:
			G.save_stat_inf.deaths[G.active_slot] += 1
			G.save_options()
		
		
	var both_death: bool = not player_alive[0] and not player_alive[1]
	
	if both_death:
		game_over(player)
		return
	if player > -1:
		respawn_timer.start()
	in_game.set_viewport_size()


func _unhandled_input(_event: InputEvent) -> void:
	for i: int in player_size:
		if Input.is_action_just_pressed("player%d_spawn" % int(i + 1)) and not player_alive[i]:
			var player_position: Vector2 = in_game.player[1 - i].global_position
			player_alive[i] = true
			player_label[i].visible = false
			var player: Player = in_game.player[i]
			player.resetComp.reset_stats()
			player.global_position = player_position
			
			if player_spawner.airship_spawner:
				player_spawner.airship_spawner.set_airship_respawn_position(i, player_position)
				player.enter_airship(player_spawner.airship_spawner.airship[i])
			
			set_process_unhandled_input(false)
			in_game.set_viewport_size()
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
	var boss_hp_bar: progressBar = $Boss/BossHP
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
