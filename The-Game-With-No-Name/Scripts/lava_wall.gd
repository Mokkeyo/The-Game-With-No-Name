extends Node2D

var lava: PackedScene = preload("res://Scenes/falling_lava.tscn")
var l: Node2D

@onready var waitTimer: Timer = $WaitTimer
@onready var lavaLenghtTimer: Timer = $LavaLenghtTimer
@onready var marker: Marker2D = $Marker2D
@onready var lavaTimer: Timer = $LavaTimer

var fallinglava: bool = false
var lenghtimer: bool = true

@export var waittime: int = 4
@export var lenghttime: int = 4

func _ready() -> void:
	waitTimer.wait_time = waittime
	lavaLenghtTimer.wait_time = lenghttime
	waitTimer.start()
	

func add_lava() -> void:
	if fallinglava:
		l = lava.instantiate()
		get_parent().add_child(l)
		l.global_position = marker.global_position + Vector2(0,0)
		if lenghtimer:
			lavaLenghtTimer.start()
			lenghtimer = false
		lavaTimer.start()

func _on_LavaTimer_timeout() -> void:
	if fallinglava:
		add_lava()

func _on_WaitTimer_timeout() -> void:
	fallinglava = true
	add_lava()

func _on_LavaLenghtTimer_timeout() -> void:
	fallinglava = false
	waitTimer.start()
	lenghtimer = true
