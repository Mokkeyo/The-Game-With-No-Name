extends Node2D
class_name AirshipSpawner

@onready var marker: Array[Marker2D] = [$Marker1, $Marker2]
@onready var airship: Array[Airship] =  [$airshipPlayer1, $airshipPlayer2]

func spawn_airship(player_alive: Array[bool]) -> void:
	for i: int in airship.size():
		airship[i].currentPlayer = i
		if player_alive[i- 1]:
			airship[i].reset_comp.set_stats()
		call_deferred("add_airship", airship[i], marker[i].global_position)
	visible = false


func activate_airship(i: int) -> void:
	var airship_i: Airship = airship[i]
	airship_i.reset_comp.reset_stats()
	airship_i.global_position = marker[i].global_position


func add_airship(airship_i: Airship, p_position: Vector2) -> void:
	remove_child(airship_i)
	get_parent().add_child(airship_i)
	airship_i.global_position = p_position
