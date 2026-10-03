extends Node2D
signal enter_door

@export var door_name: String
@export var level_number: int
@export var keys: Array[Key]
@export var door_nr: int

@onready var ping: Ping = $Ping
@onready var level_transition: LevelTransition = $LeveltransitionComponent
@onready var label: Label = $Label
@onready var interact_area: InteractionArea = %InteractArea

var key_count: int
var array_size: int

func _ready() -> void:
	interact_area.interacted.connect(level_transition.transition)
	interact_area.unhandled_input = false
	var reset_comp: EnemyResetComponent = $ResetComponent
	reset_comp.enabling_stats.connect(reset_door)
	
	for i: int in keys.size():
		keys[i].key_collected.connect(update_key_count)
	
	array_size = keys.size()
	label.text = str(array_size)
	level_transition.level_number = level_number
	level_transition.door_name = door_name
	set_process_unhandled_input(keys.size() == 0)
	
	if Save.player.door.has(door_nr):
		for key: Key in keys:
			key.disable_collision()
		open_door()


func update_key_count() -> void:
	key_count = key_count + 1
	label.text = str(array_size - key_count)
	
	if key_count == array_size:
		open_door()


func reset_door() -> void:
	if Save.player.door.has(door_nr):
		return
	
	key_count = 0
	label.text = str(array_size)
	interact_area.unhandled_input = false
	ping.visible = false


func open_door() -> void:
	label.text = str(0)
	ping.visible = true
	interact_area.unhandled_input = true
	G.door_opend.emit(door_nr)
