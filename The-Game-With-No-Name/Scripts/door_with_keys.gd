extends Node2D
signal enter_door

@export var door_name: String
@export var level_number: int
@export var keys: Array[Key]

@onready var ping: Ping = $Ping
@onready var level_transition: LevelTransition = $LeveltransitionComponent
@onready var label: Label = $Label

var key_count: int
var array_size: int

func _ready() -> void:
	var reset_comp: EnemyResetComponent = $ResetComponent
	reset_comp.resetting_stats.connect(reset_door)
	
	for i: int in keys.size():
		keys[i].key_collected.connect(update_key_count)
	
	array_size = keys.size()
	label.text = str(array_size)
	level_transition.level_number = level_number
	level_transition.door_name = door_name
	set_process_unhandled_input(false)


func _unhandled_input(_event: InputEvent) -> void:
	level_transition.check_for_transition()


func update_key_count() -> void:
	key_count = key_count + 1
	label.text = str(array_size - key_count)
	
	if key_count == array_size:
		open_door()


func reset_door() -> void:
	key_count = 0
	label.text = str(array_size)
	set_process_unhandled_input(false)
	ping.visible = false


func open_door() -> void:
	set_process_unhandled_input(true)
	ping.visible = true
