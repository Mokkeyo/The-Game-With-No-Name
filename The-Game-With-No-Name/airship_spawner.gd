extends Node2D
class_name AirshipSpawner


var body_count: int = 0
@onready var area: Area2D = $Area2D
@onready var marker: Marker2D = $Marker2D
@onready var airships: Array[Airship] = [$AirshipPlayer1, $AirshipPlayer2]
@onready var ping: Ping = $Ping

func _ready() -> void:
	for airship: Airship in airships:
		airship.reset_comp.disable_stats()
	
	set_process_unhandled_input(false)


func _unhandled_input(_event: InputEvent) -> void:
	for body: Player in area.get_overlapping_bodies():
		for i: int in range(2):
			if body.is_in_group("Player_%d" % i) and Input.is_action_just_pressed("player%d_interact" % int(i + 1)) and body.is_on_floor() and not airships[i].is_in:
				var airship: Airship = airships[i]
				airship.global_position = marker.global_position
				airship.velocity = Vector2.ZERO
				airship.reset_comp.enable_stats()



func check_for_player_in_area(body: Node2D, entered: bool) -> void:
	if body.is_in_group("Player"):
		body_count = body_count +1 if (entered) else body_count -1
		
		if (not entered and body_count == 0) or entered:
			set_process_unhandled_input(entered)


func _on_area_2d_body_entered(body: Node2D) -> void:
	check_for_player_in_area(body, true)
	ping.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	check_for_player_in_area(body, false)
	ping.visible = false
