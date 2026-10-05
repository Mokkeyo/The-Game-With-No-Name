extends Sprite2D
signal enter_door

@export var level_number: int
@export var door_name: String

@onready var marker: Marker2D = $Marker2D
@onready var ping: Ping = $Ping
@onready var level_transition: LevelTransition = $LeveltransitionComponent
@onready var interaction_area: InteractionArea = %InteractArea

var open: bool

func _ready() -> void:
	level_transition.level_number = level_number
	level_transition.door_name = door_name
	open = Save.player.kristallCollected[0] and Save.player.kristallCollected[1] and Save.player.kristallCollected[2]
	visible = open
	
	if open:
		interaction_area.interacted.connect(level_transition.transition)
