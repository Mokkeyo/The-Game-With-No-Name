@tool
extends Node2D
class_name DoorWithObj

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var animatedSprite: AnimatedSprite2D = $Door

@export_enum ("Player", "Stone", "Spiritball", "Dummy") var door_color: String = "Player"

var door_open: bool = false
@export var Door_Nr: int = 1
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
#static var temp_door: Array[int] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	resetComp.resetting_stats.connect(reset)
	if G.save_stat.door.has(Door_Nr):
		animationPlayer.play("Open")
		door_open = true
	else:
		animationPlayer.play("DoorClosed")


func reset() -> void:
	if not G.save_stat.door.has(Door_Nr):
		door_open = false
		animationPlayer.play("RESET")


func open() -> void:
	animationPlayer.play("DoorOpen")
	door_open = true
	G.emit_signal("door_opend", Door_Nr)


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		animatedSprite.play(door_color)
		set_process(false)
		return
	#----------Editor-Code--------------#
	animatedSprite.play(door_color)
