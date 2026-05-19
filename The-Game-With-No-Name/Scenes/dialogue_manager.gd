extends Node
class_name DialogueManager

static var instance: DialogueManager

var textbox: TextBox

var is_dialog_active: bool = false

func _ready() -> void:
	instance = self


func setup(tb: TextBox) -> void:
	textbox = tb

func start_dialog(black_box: bool, options: bool, speaker: String, dialog: Array, npc: Npc) -> void:
	is_dialog_active = true
	
	textbox.black_box = black_box
	textbox.options = options
	textbox.speaker_name = speaker
	textbox.dialog = dialog
	textbox.npc = npc
	
	textbox.start()


func end_dialog() -> void:
	is_dialog_active = false
	textbox.end_dialog()
