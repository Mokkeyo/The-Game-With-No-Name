extends Node2D

@export var level_number: int
@export var door_name: String = ""
@export var interaction_area: InteractionArea = null
@export var dialog_loader: DialogLoader = null

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
		interaction_area.interacted.connect(interact)
		sprite.frame = 0
	else:
		state = category.CLOSED
		interaction_area.interacted.connect(interact)
		sprite.frame = 1
	
	level_transition.level_number = level_number
	level_transition.door_name = door_name



func interact(player: Player) -> void:
	if state == category.CLOSED:
		dialog_loader.action(player)
	
	if not state == category.OPEN:
		return
		
	level_transition.transition(player)
