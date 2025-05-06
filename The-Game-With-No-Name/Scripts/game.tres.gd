extends Control

@onready var in_game: InGame = $InGame
@onready var fader: Fader = $Fader
@onready var player_label: Array[Label] = [$Player1Label, $Player2Label]
@onready var text_box: TextBox = $TextBox
@onready var lightMap: Sprite2D = $InGame/lightmap
@onready var respawn_timer: Timer = $respawnTimer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var boss_node: Control = $Boss
@onready var boss_label: Label = $Boss/Label
@onready var boss_hp_bar: progressBar = $Boss/BossHP
@onready var pause: PauseMenu = $pause

var respawnable_obj: Array[EnemyResetComponent]
var level: Node2D = null
var current_level_number: int


func _ready() -> void:
	fader.visible = true
	var start_time: float = Time.get_ticks_msec()
	connect_to_signals()
	setup_level()
	initialize_variables()
	check_for_door()
	set_player_positions()
	on_player_count_changed() 
	print("Ready duration: ", Time.get_ticks_msec() - start_time, "ms")


func setup_level() -> void:
	add_level()
	get_respawnable_objects()
	in_game.connet_camera_to_player()
	fader.fade_in()


func add_level() -> void:
	var currentLevel: PackedScene = load("res://Level/level_%d.tscn" % G.SaveStat.levelNumber)
	level = currentLevel.instantiate()
	in_game.add_level(level)
	G.playerInAirship[0] = false
	G.playerInAirship[1] = false


func get_respawnable_objects() -> void:
	respawnable_obj = []
	for obj: EnemyResetComponent in get_tree().get_nodes_in_group("respawnable"):
		respawnable_obj.append(obj)


func initialize_variables() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().paused = false
	lightMap.visible = true
	fader.visible = true


func connect_to_signals() -> void:
	G.enter_door.connect(reload)
	G.start_dialog.connect(check_for_dialog)
	G.player_died.connect(on_player_count_changed)
	G.boss_begin.connect(show_boss_hp)


func restart_level() -> void:
	initialize_variables()
	respawn_timer.stop()
	for obj: EnemyResetComponent in respawnable_obj:
		var parent: Node2D = obj.get_parent()
		 
		if not parent.is_in_group("Player"):
			obj.reset_stats()
			continue
			
		var player: Player = parent as Player
		if G.playerAlive[player.currentPlayer]:
			obj.reset_stats()
	
	set_player_positions()
	await fader.fade_in().animation_finished

	get_tree().paused = false
	pause.can_pause = true


func set_player_positions() -> void:
	for i: int in G.playerAlive.size():
		if in_game.player[i] and G.playerAlive[i]:
			in_game.player[i].global_position = G.SaveStat.checkpointPosition 


func game_over() -> void:
	pause.can_pause = false
	G.tempDoor = G.SaveStat.door
	get_tree().paused = true
	await fader.fade_out().animation_finished
	restart_level()


func reload() -> void:
	var start_time: float = Time.get_ticks_msec()
	await fader.fade_out().animation_finished
	
	get_tree().paused = false
	in_game.viewport[0].remove_child(level)
	setup_level()
	
	print("Reload duration: ", Time.get_ticks_msec() - start_time, "ms")

func check_for_door() -> void:
	G.next_level_door = ""


func on_enter_kristall() -> void:
	fader.kristall_text = current_level_number
	reload()


func on_player_count_changed() -> void:
	var both_death: bool = not G.playerAlive[0] and not G.playerAlive[1]
	
	if both_death:
		game_over()
		return
	
	respawn_timer.start()
	in_game.set_viewport_size()


func _unhandled_input(_event: InputEvent) -> void:
	for i: int in range(G.playerAlive.size()):
		if C.just_pressed(C.spawn, i) and not G.playerAlive[i]:
			G.playerAlive[i] = true
			player_label[i].visible = false
			in_game.player[i].resetComp.reset_stats()
			in_game.player[i].global_position = in_game.player[1 - i].global_position
			
			set_process_unhandled_input(false)
			in_game.set_viewport_size()
			break


func check_for_dialog() -> void:
	text_box.speaker_name = G.speaker
	text_box.dialog = G.dialog
	text_box.start()


func show_boss_hp() -> void:
	G.boss_finished.connect(hide_boss_hp)
	G.boss_value_changed.connect(change_boss_hp)
	G.boss_label_changed.connect(change_boss_label)
	change_boss_hp()
	change_boss_label()
	boss_node.visible = true


func hide_boss_hp() -> void: 
	boss_node.visible = false

func change_boss_hp() -> void: 
	boss_hp_bar.set_percent_value_int(float(G.bossHp/G.maxBossHp * 100))

func change_boss_label() -> void: 
	boss_label.text = G.bossLabel


func _on_respawnTimer_timeout() -> void:
	for i: int in range(G.playerAlive.size()):
		if not G.playerAlive[i]:
			player_label[i].visible = true
	animationPlayer.play("PlayerCanRespawn")
	set_process_unhandled_input(true)
