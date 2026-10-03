extends Node
class_name TextboxManager

var new_textbox: NewTextBox

var dialog_active: bool = false
var dialog_loader: DialogLoader = null

func _exit_tree() -> void:
	G.dialog_active = false

func setup(ntb: NewTextBox) -> void:
	new_textbox = ntb


func start_new_dialog(d: DialogLoader, dialogue_resource: DialogueResource, dialogue_start: String) -> void:
	dialog_loader = d
	G.dialog_active = true
	new_textbox.start(dialogue_resource, dialogue_start)


func end_dialog() -> void:
	if dialog_loader:
		dialog_loader.end_dialog()
		dialog_loader = null
		if Save.options.textboxCount == G.max_text:
			var ach_comp: AchievmentComponent = $achievmentComponent
			ach_comp.add_achievment()
	G.dialog_active = false
