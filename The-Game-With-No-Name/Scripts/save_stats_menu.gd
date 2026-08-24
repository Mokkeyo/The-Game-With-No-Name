extends Menu
class_name SaveStatMenu

enum States {Nothing, Copying, Erasing, EnteringName}
var state: States = States.Nothing

@export var fader: Fader

@onready var label: Label = $Label
@onready var back_button: Button = $BackButton

@onready var conformation: Control = $Conformation
@onready var conformation_text: Label = $Conformation/Label
@onready var no_button: Button = $Conformation/No

@onready var name_enterer: Control = $NameEnterer
@onready var line_edit: LineEdit = $NameEnterer/LineEdit
@onready var save_stats: Array[SaveStateButton] = [$SaveStat1, $SaveStat2, $SaveStat3, $SaveStat4] 

var selected_slot: int
var target_slot: int

func _ready() -> void:
	super._ready()
	for i: int in save_stats.size():
		var save_stat: SaveStateButton = save_stats[i]
		
		save_stat.copy_pressed.connect(copy_data)
		save_stat.erase_pressed.connect(erase_data)
		save_stat.state_pressed.connect(start_game)
		save_stat.file_exists = FileAccess.file_exists(get_save_path(i))
		if save_stat.file_exists:
			Save.load_data(i)
		save_stats[i].update_ui()


func get_save_path(slot: int) -> String:
	return "%sslot_%d.json" % [Save.SAVE_DIR, slot]  


func copy_data(save_state: int) -> void:
	selected_slot = save_state
	state = States.Copying
	label.text = "Choose a File to copy to"
	set_state_visible(false)


func set_state_visible(value: bool) -> void:
	for i: int in save_stats.size():
		if selected_slot == i:
			continue
		
		var save_stat: SaveStateButton = save_stats[i]
		
		if value:
			save_stat.stats.visible = save_stat.file_exists
			save_stat.new_game_label.visible = !save_stat.file_exists
		else:
			save_stat.stats.visible = false
			save_stat.new_game_label.visible = false


func erase_data(save_state: int) -> void:
	selected_slot = save_state
	state = States.Erasing
	enter_conformation("Erase Data?")


func _unhandled_input(event: InputEvent) -> void:
	if state == States.Nothing:
		super._unhandled_input(event)
		return
	
	if state == States.EnteringName:
		return
	
	if Input.is_action_just_pressed("back"):
		return_to_default()


func show_normal_text() -> void:
	label.text = "Choose a file"
	back_button.text = "back"


func start_fader(save_state: int) -> void:
	Save.active_slot = save_state
	get_tree().paused = true
	await fader.fade_out().animation_finished
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func start_game(save_state: int) -> void:
	if state == States.Copying:
		enter_conformation("Copy Data?")
		target_slot = save_state
		return
	
	if save_stats[save_state].file_exists:
		Save.load_data(save_state)
		start_fader(save_state)
	else:
		back_button.text = "Cancel"
		selected_slot = save_state
		state = States.EnteringName
		name_enterer.visible = true
		line_edit.grab_focus()


func start_new_game() -> void:
	Save.start_new_game(selected_slot)
	start_fader(selected_slot)


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.begins_with(" "):
		line_edit.editable = true
		line_edit.text = ""


func _on_line_edit_text_submitted(_new_text: String) -> void:
	if _new_text == "" or _new_text == " ":
		return
		
	Save.options.playerName[selected_slot] = line_edit.text
	line_edit.release_focus()
	Save.save_options() 
	start_new_game()


func _on_yes_pressed() -> void:
	var save_stat: SaveStateButton = save_stats[selected_slot]
	match state:
		States.Erasing:
			save_stat.file_exists = false
			Save.delete_data(selected_slot)
			save_stat.update_ui()
	
		States.Copying:
			var target_stat: SaveStateButton = save_stats[target_slot]
			save_stat.file_exists = true
			target_stat.file_exists = true
			Save.options.playerName[target_slot] = \
				Save.options.playerName[selected_slot]
			Save.options.deaths[target_slot] = \
				Save.options.deaths[selected_slot]
			Save.save_options()
			Save.save_data(target_slot)
			
			target_stat.update_ui()
	
	return_to_default()


func _on_no_pressed() -> void:
	return_to_default()


func enter_conformation(text: String) -> void:
	back_button.text = "cancel"
	conformation_text.text = text
	conformation.visible = true
	no_button.grab_focus()


func exit() -> void:
	if state == States.Nothing:
		super.exit()
		return
	
	return_to_default()


func return_to_default() -> void:
	show_normal_text()
	line_edit.text = ""
	save_stats[selected_slot].grab_focus()
	state = States.Nothing
	conformation.visible = false
	set_state_visible(true)
	name_enterer.visible = false


func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:
		return
	
	await get_tree().process_frame
	
	if state == States.Nothing:
		return
	
	return_to_default()
