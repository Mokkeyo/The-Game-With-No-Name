extends Control
class_name AchievmentInformer

@onready var label: Label = $CanvasLayer/Label
@onready var label2: Label = $CanvasLayer/Control/Label2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_fps: int = 0
var queued_achievements: Array[String] = []
var is_playing: bool = false

func _ready() -> void: 
	G.achievment_collected.connect(_on_achievement_collected)

func _process(_delta: float) -> void: 
	update_fps_label()


func update_fps_label() -> void:
	if G.SaveStatInf.printFps:
		var current_fps: int= int(Engine.get_frames_per_second())
		if not current_fps == last_fps:
			label.text = "Fps: %d" % current_fps
			last_fps = current_fps
	else:
		if label.text != "":
			last_fps = 0
			label.text = ""



func _on_achievement_collected(achievement_name: String) -> void:
	queued_achievements.append(achievement_name)

	if not is_playing:
		_process_next_achievement()


func _process_next_achievement() -> void:
	if queued_achievements.is_empty():
		is_playing = false
		return

	is_playing = true
	var achievement_name:String = queued_achievements.pop_front()

	label2.text = achievement_name
	print(achievement_name)

	var sprite_path: String= "CanvasLayer/Control/" + achievement_name
	var sprite: Sprite2D = get_node_or_null(sprite_path)

	if sprite:
		sprite.visible = true
	else:
		push_warning("Achievement sprite not found at: " + sprite_path)
		_process_next_achievement()
		return

	animation_player.play("Achievment")
	await animation_player.animation_finished

	sprite.visible = false
	_process_next_achievement()
