extends Node2D

@onready var door: Sprite2D = $Door
@onready var achievmentComponent: AchievmentComponent = $achievmentComponent
@onready var level_transition: LevelTransition = $LeveltransitionComponent
@onready var ping: Ping = $Ping

@export var level_number: int
@export var door_name: String = ""
@export var state: category

var parent: Node2D
var current_level: int
var body_count: int
enum category{OPEN, DESTROYED}


func _ready() -> void:
	parent = get_parent()
	parent.set_process_unhandled_input(false)
	
	current_level = G.SaveStat.levelNumber
	level_transition.level_number = level_number
	level_transition.door_name = door_name
	
	if G.SaveStat.kristallCollected[level_number-2]:
		state = category.DESTROYED
	
	door.frame = 1 if state == category.DESTROYED else 0


func _unhandled_input(_event: InputEvent) -> void:
	if state == category.DESTROYED:
		return
	
	if level_transition.check_for_transition() and current_level == 0:
		achievmentComponent.add_achievment()


func check_for_player_in_area(body: Node2D, entered: bool) -> void:
	if body.is_in_group("Player") and state == category.OPEN:
		body_count = body_count +1 if (entered) else body_count -1
		
		if (not entered and body_count == 0) or entered:
			ping.visible = entered
			parent.set_process_unhandled_input(entered)


func _on_area_2d_body_entered(body: Node2D) -> void:check_for_player_in_area(body, true)
func _on_area_2d_body_exited(body: Node2D) -> void:check_for_player_in_area(body, false)
