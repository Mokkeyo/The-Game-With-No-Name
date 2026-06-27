extends Node2D

@onready var buschiFace: Sprite2D = $BuschieFace

func start_tween(y_position: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(buschiFace, "position", Vector2(0, y_position), 0.2)


func _on_Quit_area_body_entered(body: Player) -> void:
	if body.is_in_group("Player_0"):
		start_tween(-26)


func _on_Quit_area_body_exited(body: Player) -> void:
	if body.is_in_group("Player_0"):
		start_tween(-5)
