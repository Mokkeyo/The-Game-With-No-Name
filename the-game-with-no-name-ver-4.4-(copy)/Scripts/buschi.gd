extends Npc

@onready var buschiFace: Sprite2D = $BuschieFace
@export var level_number: int = 0
@export var door_name: String
var index: int = 0


func _unhandled_input(_event: InputEvent) -> void:
	if npcArea.check_for_player():
		dialogLoader.player = npcArea.player
		if dialogLoader.has_dialog(D.buschi, 0) and index == 0:
			index = 1
		dialogLoader.start_dialogue(index)


func end_dialog() -> void:
	if dialogLoader.player:
		dialogLoader.finish_dialogue()
		dialogLoader.check_for_dialog_collected(index)


func start_tween(y_position: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(buschiFace, "position", Vector2(0, y_position), 0.2)


func on_yes_pressed() -> void:
	G.SaveStat.levelNumber = 0
	G.emit_signal("enter_door")



func _on_Quit_area_body_entered(body: Player) -> void:
	if body.is_in_group("Player_0"):
		start_tween(-26)


func _on_Quit_area_body_exited(body: Player) -> void:
	if body.is_in_group("Player_0"):
		start_tween(-5)
