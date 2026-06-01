extends Npc

@export var level_number: int
@export var door_name: String = ""

@onready var marker: Marker2D = $Marker2D
@onready var level_transition: LevelTransition = $LeveltransitionComponent
@onready var sprite: Sprite2D = $BossDoorOpen

enum category {CLOSED, OPEN, DESTROYED}
var state: category = category.CLOSED


func _ready() -> void:
	if Save.player.kristallCollected[level_number-2]:
		state = category.DESTROYED
		sprite.frame = 2
	elif Save.player.kristallCount == 2:
		state = category.OPEN
		sprite.frame = 0
	else:
		state = category.CLOSED
		sprite.frame = 1
	
	level_transition.level_number = level_number
	level_transition.door_name = door_name


func _unhandled_input(_event: InputEvent) -> void:
	if npcArea.check_for_player() and state == category.CLOSED:
		dialogLoader.action(npcArea.player, self)
	
	if not state == category.OPEN:
		return
		
	level_transition.check_for_transition()
	
