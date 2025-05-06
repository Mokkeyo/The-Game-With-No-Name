extends Node2D
signal enter_door

@export var door_name: String
@export var level_number: int
@export var keyCount: int = 0

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var ping: Ping = $Ping
@onready var key: Array[Sprite2D] = [$Schlüssel, $"Schlüssel2", $"Schlüssel3"]
@onready var keyTurned: Array[Sprite2D] = [$"Door_With_Keys/Schlüssel(gedreht)", $"Door_With_Keys/Schlüssel(gedreht)2", $"Door_With_Keys/Schlüssel(gedreht)3"]
@onready var level_transition: LevelTransition = $LeveltransitionComponent

var key_collected: Array = [false, false, false]


func _ready() -> void:
	level_transition.level_number = level_number
	level_transition.door_name = door_name
	set_process_unhandled_input(false)

func _unhandled_input(_event: InputEvent) -> void:
	level_transition.check_for_transition()


func update_key_count(i: int) -> void:
	if not key_collected[i]:
		key_collected[i] = true
		key[i].visible = false
		keyCount += 1
	
	if keyCount >= i - 1:
		keyTurned[i - 1].visible = true
	
	if keyCount == key.size():
		animationPlayer.play("turn_key")


func _on_Area2D_body_entered(_body: Player) -> void: update_key_count(0)
func _on_Area2D2_body_entered(_body: Player) -> void: update_key_count(1)
func _on_Area2D3_body_entered(_body: Player) -> void: update_key_count(2)

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	set_process_unhandled_input(true)
	ping.visible = true
