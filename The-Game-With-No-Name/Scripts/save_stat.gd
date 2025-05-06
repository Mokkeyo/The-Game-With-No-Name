extends Button
class_name SaveStateButton

@export var saveState: int = 0
@export var menu: SaveStatMenu

@onready var stats: Control = $Stats
@onready var new_game_label: Control = $NewGameLabel
@onready var name_label: Label = $Stats/PlayerNameLabel
@onready var star: Sprite2D = $Stats/Star
@onready var death_count: Label = $Stats/DeathCount
@onready var copy_panel: Panel = $CopyPanel
@onready var conformation: Control = $Delete
@onready var conformation_text: Label = $"Delete/Delete?"
@onready var no_ping: Sprite2D = $Delete/Panel4/PingNo
@onready var yes_ping: Sprite2D = $Delete/Panel3/PingYes
@onready var no_button: Button = $Delete/Panel4/Panel2/No

enum States {Nothing, Copying, Ereasing, EnteringName}
static var state: States = States.Nothing

var file_exists: bool

func _ready() -> void: 
	if saveState == 1:
		state = States.Nothing
	set_process(false)
	set_process_unhandled_input(false)
	initialize_ui()


func initialize_ui() -> void:
	file_exists = FileAccess.file_exists(G.save_path + G.save_file_name[saveState])
	G.path =  saveState
	if file_exists:
		G.load_data()
	show_ui(saveState - 1)


func show_ui(file: int) -> void:
	stats.visible = file_exists
	new_game_label.visible = not file_exists
	name_label.text = G.SaveStatInf.playerName[file]
	star.visible = G.SaveStat.finished[0]
	death_count.text = "Deaths: " + (str(G.SaveStatInf.deaths[file]) if G.SaveStatInf.deaths[file] < 1000 else "999+ :(")
	set_kristall_visibility()


func initialize_copied_ui() -> void:
	show_ui(menu.copy_data_from_save - 1)


func set_kristall_visibility() -> void:
	var stateKristall: Array[TextureRect] = [
		$Stats/HC/Kristall1, $Stats/HC/Kristall2, $Stats/HC/Kristall3, $Stats/HC/Kristall4, 
		$Stats/HC/Kristall5, $Stats/HC/Kristall6, $Stats/HC/Kristall7, $Stats/HC/Kristall8]
		
	for i: int in stateKristall.size():
		stateKristall[i].visible = G.SaveStat.kristallCollected[i]


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("erease") and file_exists:
		G.path = saveState
		erease_data()
	elif Input.is_action_just_pressed("copy"):
		G.path = saveState
		copy_data()
	if not state == States.Nothing and Input.is_action_just_pressed("back"):
		menu.set_process_unhandled_input(false)
		hide_delete_copy_conformation()


func show_delete_copy_conformation(new_text: String) -> void:
	conformation_text.text = new_text
	conformation.visible = true
	no_button.grab_focus()


func hide_delete_copy_conformation() -> void:
	if state == States.Copying:
		menu.show_normal_text()
	state = States.Nothing
	conformation.visible = false
	grab_focus()


func start_game_or_copy() -> void:
	if state == States.Copying:
		show_delete_copy_conformation("copy data?")
	else:
		release_focus()
		menu.set_process_unhandled_input(true)
		state = States.EnteringName
		menu.start_game()
		menu.set_process(false)


func erease_data() -> void:
	menu.set_process(false)
	state = States.Ereasing
	show_delete_copy_conformation("delete data?")


func copy_data() -> void:
	menu.set_process(false)
	menu.copy_data_from_save = saveState
	menu.show_copy_data_text()
	G.load_data()
	state = States.Copying



func show_yes_ping(visibility: bool) -> void:
	yes_ping.visible = visibility
	no_ping.visible = not visibility


func _on_Yes_focus_entered() -> void:
	show_yes_ping(true)


func _on_No_focus_entered() -> void:
	show_yes_ping(false)


func _on_No_pressed() -> void:
	hide_delete_copy_conformation()


func _on_Yes_pressed() -> void:
	if state == States.Copying:
		G.path = saveState
		file_exists = true
		G.SaveStatInf.playerName[saveState - 1] = G.SaveStatInf.playerName[menu.copy_data_from_save - 1]
		G.save_options()
		G.save_data()
		initialize_copied_ui()
	elif state == States.Ereasing:
		file_exists = false
		G.delete_data()
		initialize_ui()
	hide_delete_copy_conformation()


func _on_focus_entered() -> void:
	if not G.path == saveState:
		G.path = saveState

	if state == States.Nothing:
		set_process_unhandled_input(true)


func _on_focus_exited() -> void:
	if state == States.Nothing:
		set_process_unhandled_input(false)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and state == States.Nothing:
		G.path = saveState
		
		if not file_exists:
			return
			
		var mouse_event: InputEventMouseButton = event
		match mouse_event.button_index:
			MOUSE_BUTTON_MIDDLE:
					copy_data()
			MOUSE_BUTTON_RIGHT:
					erease_data()


func _on_pressed() -> void:
	if state == States.Nothing:
		start_game_or_copy()
