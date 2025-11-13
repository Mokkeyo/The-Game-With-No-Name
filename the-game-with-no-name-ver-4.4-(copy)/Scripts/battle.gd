extends Node2D

var time: float = G.battle_time
var level: Node2D = null

@onready var in_game: Node2D = $InGame
@onready var timerLabel: Label = $CanvasLayer/TimerLabel
@onready var timer: Timer = $Timer
@onready var label: Array[Label] = [$CanvasLayer/Player1Won, $CanvasLayer/Player2Won, $CanvasLayer/Draw]
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var fadeInPlayer: AnimationPlayer = $FadeIn

var pause_game: bool = true
var showVictory: bool = true

func _ready() -> void:
	loadArena()
	if G.battle_time != 0:
		timerLabel.visible = true
		timer.start()


func _process(_delta: float) -> void:
	if showVictory:
		if not G.playerAlive[0] and not G.playerAlive[1] :
			declareVictor(2, true)
		elif not G.playerAlive[0] and G.playerAlive[1]:
			declareVictor(1, true)
		else:
			declareVictor(0, true)
	
	if time == 0 and pause_game and timer:
		pause_game = false
		
		if G.battlePlayerHeal[0] == G.battlePlayerHeal[1]:
			declareVictor(2, false)
		elif G.battlePlayerHeal[0] > G.battlePlayerHeal[1]:
			declareVictor(1, false)
		else:
			declareVictor(0, false)
	
		get_tree().paused = true
	
	if G.battle_time != 0:
		timerLabel.text = str(time)


func declareVictor(i: int, startTimer: bool) -> void:
	if startTimer:
		timer.start(1)
	showVictory = false
	label[i].visible = true
	animationPlayer.play("DeclareVictory")


func loadArena() -> void:
	var arena: PackedScene = load("res://Arena/Arena_%d.tscn" % G.arena)
	level = arena.instantiate()
	in_game.add_child(level)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	fadeInPlayer.play("FadeIn")


func _on_FadeIn_animation_finished(_anim_name: String) -> void:
	G.battle_damage = false
	G.playerAlive[0] = true
	G.playerAlive[1] = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Szenen/BattleMode.tscn")


func _on_Timer_timeout() -> void:
	if time != 0:
		time = time - 1
		timer.start()
