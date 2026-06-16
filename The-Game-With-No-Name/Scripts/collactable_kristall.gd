extends Npc
class_name collactable_kristall

@export var kristall: int = 1
@export var level_number: int = 1
@onready var npc_area: NpcArea = $NPCArea
@onready var dialog_loader: DialogLoader = $DialogueLoader

func _ready() -> void:
	var color: Array[Color] = [
		Color.RED, Color. BLUE, Color.GREEN, Color.YELLOW, Color.DEEP_PINK, 
		Color.ORANGE_RED, Color.DIM_GRAY, Color.LAVENDER_BLUSH
		]
	
	var index: int = kristall - 1
	var kristallParticle: GPUParticles2D = $KristallParticle
	kristallParticle.modulate = color[index]
	var animationPlayer: AnimationPlayer = $AnimationPlayer
	animationPlayer.play("default")
	var sprite: Sprite2D = $Kristall
	sprite.frame = index


func _unhandled_input(_event: InputEvent) -> void:
	if npc_area.check_for_player():
		dialog_loader.action(npc_area.player, self)


func end_dialog() -> void:
	print("ending dialog")
	if not Save.player.kristallCollected[kristall - 1]:
		Save.player.checkpointActive = false
		Save.player.kristallCollected[kristall - 1] = true
		Save.player.kristallCount += 1
