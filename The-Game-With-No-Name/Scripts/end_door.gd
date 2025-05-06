extends Sprite2D
signal enter_door

@export var level_number: int
@export var door_name: String

@onready var area: Area2D = $Area2D
@onready var marker: Marker2D = $Marker2D
@onready var ping: Ping = $Ping
@onready var level_transition: LevelTransition = $LeveltransitionComponent
var open: bool

func _ready() -> void:
	level_transition.level_number = level_number
	level_transition.door_name = door_name
	open = G.SaveStat.kristallCollected[0] and G.SaveStat.kristallCollected[1] and G.SaveStat.kristallCollected[2]
	set_process_unhandled_input(open)
	visible = open


func _unhandled_input(_event: InputEvent) -> void:
	level_transition.check_for_transition()


func _on_Area2D_body_entered(_body: Player) -> void:
	ping.visible = true


func _on_Area2D_body_exited(_body: Player) -> void:
	ping.visible = false
