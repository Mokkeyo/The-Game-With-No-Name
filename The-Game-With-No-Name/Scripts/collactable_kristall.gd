extends Node2D
class_name collactable_kristall

@export var kristall: int = 1
@export var level_number: int = 1
@onready var interact_area: InteractionArea = $NPCArea
@onready var dialog_loader: DialogLoader = $DialogueLoader


func _ready() -> void:
	if not interact_area.interacted.is_connected:
		interact_area.interacted.connect(dialog_loader.action)
	dialog_loader.ending_dialog.connect(end_dialog)
	var color: Array[Color] = [
		Color.RED, Color. BLUE, Color.GREEN, Color.YELLOW, Color.DEEP_PINK, 
		Color.ORANGE_RED, Color.DIM_GRAY, Color.LAVENDER_BLUSH
		]
	var sprite: Sprite2D = $Kristall
	var tween: Tween = create_tween()
	
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(sprite, "position:y", - 5.0, 2.0)
	tween.tween_property(sprite, "position:y", 5.0, 2.0)
	
	var index: int = kristall - 1
	var kristallParticle: GPUParticles2D = $Kristall/KristallParticle
	kristallParticle.modulate = color[index]
	sprite.frame = index


func end_dialog() -> void:
	if not Save.player.kristallCollected[kristall - 1]:
		Save.player.checkpointActive = false
		Save.player.kristallCollected[kristall - 1] = true
		Save.player.kristallCount += 1
