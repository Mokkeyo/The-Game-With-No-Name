extends Node
class_name TextboxManager

static var instance: TextboxManager

var textbox: TextBox
var new_textbox: NewTextBox

var is_dialog_active: bool = false
var npc: Npc = null

func _ready() -> void:
	instance = self


func setup(tb: TextBox, ntb: NewTextBox) -> void:
	textbox = tb
	new_textbox = ntb

func start_new_dialog(n: Npc, dialogue_resource: DialogueResource, dialogue_start: String) -> void:
	npc = n
	is_dialog_active = true
	new_textbox.start(dialogue_resource, dialogue_start)


func end_dialog() -> void:
#	AI.check_if_chatter_unlocked()
	if npc:
		npc.end_dialog()
		npc = null
	is_dialog_active = false
