extends Menu
class_name SaveStatMenu

@export var fader: Fader

@onready var label: Label = $Label
@onready var back_button: Button = $BackButton

@onready var name_enterer: Control = $NameEnterer
@onready var line_edit: LineEdit = $NameEnterer/LineEdit
@onready var save_stats: Array[SaveStateButton] = [$SaveStat1, $SaveStat2, $SaveStat3, $SaveStat4] 

var copy_data_from_save: int

func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	if Input.is_action_just_pressed("back"):
		var path: int = G.path - 1
		save_stats[path].grab_focus()
		name_enterer.visible = false
		set_process_unhandled_input(false)


func show_normal_text() -> void:
	label.text = "Choose a file"
	back_button.text = "back"
	update_save_state_visibility(true)


func show_copy_data_text() -> void:
	label.text = "Choose a File to copy to"
	back_button.text = "Cancel"
	update_save_state_visibility(true)


func update_save_state_visibility(is_copy: bool) -> void:
	for saveStateButton: SaveStateButton in save_stats:
		saveStateButton.copy_panel.visible = is_copy and saveStateButton.saveState != copy_data_from_save or not is_copy


func start_fader() -> void:
	get_tree().paused = true
	await  fader.fade_out().animation_finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func start_new_game() -> void:
	G.start_new_game()
	start_fader()


func start_game() -> void:
	if save_stats[G.path - 1].file_exists:
		G.load_data()
		start_fader()
	else:
		name_enterer.visible = true
		line_edit.grab_focus()


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.begins_with(" "):
		line_edit.text = ""


func _on_line_edit_text_submitted(_new_text: String) -> void:
	G.SaveStatInf.playerName[G.path - 1] = line_edit.text
	line_edit.release_focus()
	G.save_options() 
	start_new_game()
