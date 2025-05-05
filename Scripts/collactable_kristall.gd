extends Npc
class_name collactable_kristall

@onready var level_transition: LevelTransition = $LeveltransitionComponent
@export var kristall: int = 1
@export var level_number: int = 1


func _ready() -> void:
	level_transition.level_number = level_number
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
	if npcArea.check_for_player():
		dialogLoader.player = npcArea.player
		dialogLoader.start_dialogue_no_check()


func end_dialog() -> void:
	if not G.SaveStat.kristallCollected[kristall - 1]:
		G.SaveStat.kristallCollected[kristall - 1] = true
		G.SaveStat.kristallCount += 1
	
	dialogLoader.finish_dialogue()
	dialogLoader.check_for_dialog_collected_no_check()
	
	level_transition.transition()
