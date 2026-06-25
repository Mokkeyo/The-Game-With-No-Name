extends Node
class_name TextboxManager

static var instance: TextboxManager

var textbox: TextBox
var new_textbox: NewTextBox

var is_dialog_active: bool = false
var dialog_loader: DialogLoader = null

func _ready() -> void:
	instance = self


func setup(tb: TextBox, ntb: NewTextBox) -> void:
	textbox = tb
	new_textbox = ntb

func start_new_dialog(d: DialogLoader, dialogue_resource: DialogueResource, dialogue_start: String) -> void:
	dialog_loader = d
	is_dialog_active = true
	new_textbox.start(dialogue_resource, dialogue_start)


func end_dialog() -> void:
	if dialog_loader:
		dialog_loader.end_dialog()
		dialog_loader = null
		if Save.options.textboxCount == G.max_text:
			var ach_comp: AchievmentComponent = $achievmentComponent
			ach_comp.add_achievment()
	is_dialog_active = false
