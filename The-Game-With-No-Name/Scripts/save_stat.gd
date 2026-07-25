extends Button
class_name SaveStateButton

signal state_pressed(index: int)
signal copy_pressed(index: int)
signal erase_pressed(index: int)

@export var saveState: int = 0

@onready var stats: Control = $Stats
@onready var new_game_label: Control = $NewGameLabel
@onready var name_label: Label = $Stats/PlayerNameLabel
@onready var star: Sprite2D = $Stats/Star
@onready var death_count: Label = $Stats/DeathCount

@onready var crystal_icons: Array[TextureRect] = [
	$Stats/HC/Kristall1, 
	$Stats/HC/Kristall2, 
	$Stats/HC/Kristall3, 
	$Stats/HC/Kristall4, 
	$Stats/HC/Kristall5, 
	$Stats/HC/Kristall6, 
	$Stats/HC/Kristall7, 
	$Stats/HC/Kristall8,
]

var file_exists: bool

func _ready() -> void: 
	set_process(false)
	set_process_unhandled_input(false)


func update_ui() -> void:
	stats.visible = file_exists
	new_game_label.visible = !stats.visible
	
	if !file_exists:
		return
	
	name_label.text = Save.options.playerName[saveState]
	star.visible = Save.player.finished[0]
	death_count.text = get_death_text()
	
	set_kristall_visibility()

func get_death_text() -> String:
	var deaths: int = Save.options.deaths[saveState]
	return "Deaths: %s" % (str(deaths) if deaths < 1000 else "999+ :(")

func set_kristall_visibility() -> void:
	for i: int in crystal_icons.size():
		crystal_icons[i].visible = Save.player.kristallCollected[i]


func _unhandled_input(_event: InputEvent) -> void:
	if !file_exists:
		set_process_unhandled_input(false)
		return
	
	if Input.is_action_just_pressed("erase"):
		erase_pressed.emit(saveState)
		return
	
	if Input.is_action_just_pressed("copy"):
		copy_pressed.emit(saveState)


func _on_focus_entered() -> void:
	set_process_unhandled_input(true)


func _on_focus_exited() -> void:
	set_process_unhandled_input(false)


func _on_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	
	var mouse: InputEventMouseButton = event as InputEventMouseButton
	
	if !mouse.pressed:
		return
	
	if !file_exists:
		return
		
	match mouse.button_index:
		MOUSE_BUTTON_MIDDLE:
				copy_pressed.emit(saveState)
		MOUSE_BUTTON_RIGHT:
				erase_pressed.emit(saveState)


func _on_pressed() -> void:
	state_pressed.emit(saveState)
