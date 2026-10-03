extends Node2D
class_name Door

@onready var door: Sprite2D = $Door
@onready var achievmentComponent: AchievmentComponent = $achievmentComponent
@onready var level_transition: LevelTransition = $LeveltransitionComponent
@onready var ping: Ping = $Ping
@onready var interaction_area: InteractionArea = %InteractArea

@export var level_number: int
@export var door_name: String = ""
@export var state: category = category.OPEN

var current_level: int
var body_count: int
enum category{OPEN, DESTROYED}


func _ready() -> void:
	current_level = Save.player.levelNumber
	level_transition.level_number = level_number
	level_transition.door_name = door_name
	
	if Save.player.kristallCollected[level_number-2]:
		state = category.DESTROYED
	
	#if not state == category.DESTROYED:
	interaction_area.interacted.connect(transition)

	door.frame = 1 if state == category.DESTROYED else 0


func transition(player: Player) -> void:
	if current_level == 0:
		achievmentComponent.add_achievment()
	level_transition.transition(player)
