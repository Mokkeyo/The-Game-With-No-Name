extends Node2D
class_name AirshipSpawner


var body_count: int = 0
@onready var area: InteractionArea = $InteractArea
@onready var marker: Marker2D = $Marker2D
@onready var airships: Array[Airship] = [$AirshipPlayer1, $AirshipPlayer2]
@onready var ping: Ping = $Ping

func _ready() -> void:
	for airship: Airship in airships:
		airship.reset_comp.disable_stats()
		
	set_process_unhandled_input(false)
	area.interacted.connect(spawn)

func spawn(body: Player) -> void:
		for i: int in range(2):
			if body.is_in_group("Player_%d" % i) and Input.is_action_just_pressed("player%d_interact" % int(i + 1)) and body.is_on_floor() and not airships[i].is_in:
				var airship: Airship = airships[i]
				airship.global_position = marker.global_position
				airship.velocity = Vector2.ZERO
				airship.reset_comp.enable_stats()
