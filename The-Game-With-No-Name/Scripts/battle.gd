extends Node2D

@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var timer: Timer = $Timer
@onready var hpbar: Array[HealthBar] = [$CanvasLayer2/Player1/HPBar, $CanvasLayer2/Player2/HPBar]
@onready var manabar: Array[HealthBar] = [$CanvasLayer2/Player1/Mana, $CanvasLayer2/Player2/Mana]
@onready var players: Array[Player] = [$Player1, $Player2]

var last_second: int = -1

func _ready() -> void:
	var in_game: Node2D = $InGame
	loadArena(in_game)
	G.level_viewport = in_game
	G.player_died.connect(player_died)
	G.health_value_changed.connect(on_health_value_changed)
	G.mana_value_changed.connect(on_mana_value_changed)
	
	for player: Player in players:
		player.health_component.max_health = BattleData.hp * 20
		player.health_component.health = BattleData.hp * 20
	
	if not BattleData.time == 0:
		timer.wait_time = BattleData.time
		timer_label.visible = true
		timer.start()


func _process(_delta: float) -> void:
	var seconds: int = int(timer.time_left)

	if seconds != last_second:
		last_second = seconds
		timer_label.text = str(seconds)


func player_died(_player: float) -> void:
	await get_tree().process_frame
	check_victory()


func check_victory() -> void:
	timer.stop()
	if not players[0].is_alive and not players[1].is_alive:
		declareVictor(2)
	elif not players[0].is_alive and players[1].is_alive:
		declareVictor(1)
	else:
		declareVictor(0)
	
	get_tree().paused = true

func declareVictor(i: int) -> void:
	var label: Array[Label] = [%Player1Won, %Player2Won, %Draw]
	var animationPlayer: AnimationPlayer = $AnimationPlayer
	
	label[i].visible = true
	animationPlayer.play("DeclareVictory")


func loadArena(in_game: Node2D) -> void:
	var arena: PackedScene = load("res://Arena/Arena_%d.tscn" % BattleData.arena)
	
	if arena == null:
		push_error("No Arena Found")
		return
	
	var level: Node2D = arena.instantiate()
	in_game.add_child(level)
	
	set_player_position(level)


func set_player_position(level: Node2D) -> void:
	var spawn_1: Marker2D = level.get_node_or_null("Marker2D")
	var spawn_2: Marker2D = level.get_node_or_null("Marker2D2")
	
	players[0].global_position = spawn_1.global_position
	players[1].global_position = spawn_2.global_position


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
#	var fader: Fader = $Fader
	
#	await fader.fade_in().animation_finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/battle_mode_menu.tscn")


func _on_Timer_timeout() -> void:
	if players[0].health_component.health == players[1].health_component.health:
		declareVictor(2)
	elif players[0].health_component.health > players[1].health_component.health:
		declareVictor(1)
	else:
		declareVictor(0)


func on_health_value_changed(player_number: int, health_value: int) -> void:
	var bar: HealthBar = hpbar[player_number]
	var health_comp: HealthComponent = players[player_number].health_component
	var health: int = int(health_value/ health_comp.max_health * 100)
	bar.set_value_int(health)


func on_mana_value_changed(player_number: int, mana_value: float) -> void:
	var bar: HealthBar = manabar[player_number]
	if mana_value >= 99:
		bar.set_value_int(mana_value)
	else:
		bar.set_percent_value_int(mana_value)
