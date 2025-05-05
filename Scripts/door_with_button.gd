extends Node2D

@onready var button: AnimatedSprite2D = $AnimatedSprite2D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var characterBody: Dummy = $CharacterBody2D
@onready var door: AnimatedSprite2D = $Door_closed

enum objects {PLAYER, ROCK, WAND ,DUMMY}
@export var recuired_input: objects

var downAnimation: Array[String] = 	["ButtonDown", "ButtonDown(red)", "ButtonDown(yellow)"]
var upAnimation: Array[String] = 	["ButtonUp", "ButtonUp(red)", "ButtonUp(yellow)"]
var doorAnimation: Array[String] = 	["Door", "Door(red)", "Door(yellow)", "Door(white)"]
var group: Array[String] =			["Player", "Stone", "wand", ""]

var door_open: bool = false
@export var Door_Nr: int = 1
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent

func _ready() -> void:
	resetComp.resetting_stats.connect(reset)
	characterBody.connect("defeated", Callable(self, "open"))
	door.play(doorAnimation[recuired_input])
	if G.SaveStat.door.has(Door_Nr):
		if recuired_input != objects.DUMMY:
			button.play(downAnimation[recuired_input])
		animationPlayer.play("Open")
		door_open = true

	else:
		animationPlayer.play("DoorClosed")
		if not recuired_input == objects.DUMMY:
			button.play(upAnimation[recuired_input])
		else:
			button.visible = false
			characterBody.visible = true


func reset() -> void:
	if not G.SaveStat.door.has(Door_Nr):
		door_open = false
		animationPlayer.play("RESET")
		if not recuired_input == objects.DUMMY:
			button.play(upAnimation[recuired_input])
		else:
			button.visible = false
			characterBody.visible = true


func _on_Area2D_body_entered(body: Node2D) -> void: check_required_input(body)
func _on_Area2D_area_entered(area: Area2D) -> void: check_required_input(area)


func check_required_input(body: Node2D) -> void:
	if not recuired_input == objects.DUMMY:
		if body.is_in_group(group[recuired_input]) and not door_open:
			open()
			G.tempDoor.append(Door_Nr)


func open() -> void:
	if not recuired_input == objects.DUMMY:
		button.play(downAnimation[recuired_input])
	animationPlayer.play("DoorOpen")
	door_open = true
