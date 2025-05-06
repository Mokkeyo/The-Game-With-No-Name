extends Node2D

@onready var marker: Array[Marker2D] = [$Player, $Player2]
var airship: PackedScene
var a: Airship

func _ready() -> void:
	for i: int in range(G.playerAlive.size()):
		if G.playerAlive[i]:
			airship = load(str("res://Player/Scenes/airship_player_",i + 1,".tscn"))
			a = airship.instantiate()
			get_parent().call_deferred("add_child", a)
			a.global_position = marker[i].global_position
	queue_free()
