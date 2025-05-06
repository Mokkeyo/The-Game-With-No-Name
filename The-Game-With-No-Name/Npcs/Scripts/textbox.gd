extends Control
class_name TextBox

@onready var control: Control = $Control
@onready var speaker: RichTextLabel = $Control/Speaker
@onready var normal_box: Control = $Control/Panel
@onready var black_box: Control = $Control/Panel2
@onready var text_box: RichTextLabel = $Control/RichTextLabel
@onready var ping: Ping = $Control/Ping
@onready var timer: Timer = $Control/Timer
@onready var decide_box: DecideBox = $DecideBox

enum State {READING, FINISHED}

var dialog: Array = []
var speaker_name: String = ""
var text_length: int = 0

var dialog_index: int = 0
var state: State = State.FINISHED
var tween: Tween = null


func _ready() -> void:
	set_process_unhandled_input(false)


func start() -> void:
	dialog_index = 0
	control.visible = true
	speaker.visible = true
	normal_box.visible = not G.black_box
	black_box.visible = G.black_box
	text_box.visible = true
	_load_dialog()
	set_process_unhandled_input(true)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("enter"):
		match state:
			State.READING:
				if tween:
					tween.stop()
				text_box.visible_characters = text_length
				_on_tween_completed()
			State.FINISHED:
				if dialog_index + 1 < dialog.size():
					dialog_index += 1
					_load_dialog()
				else:
					set_process_unhandled_input(false)
					if not G.options:
						decide_box.enter()
					else:
						control.visible = false
						timer.start()


func _load_dialog() -> void:
	var current_line: String = dialog[dialog_index]
	text_length = current_line.length()
	state = State.READING
	ping.visible = false
	
	text_box.text = current_line
	speaker.text = speaker_name
	text_box.visible_characters = 0
	
	tween = create_tween()
	tween.finished.connect(_on_tween_completed)
	tween.tween_property(text_box, "visible_characters", text_length, 2)


func _on_tween_completed() -> void:
	state = State.FINISHED
	ping.visible = true


func _on_timer_timeout() -> void:
	G.npc.end_dialog()
	G.npc = null
