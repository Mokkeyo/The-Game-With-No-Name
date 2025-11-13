extends Node2D

@onready var marker: Array[Marker2D] = [$Player, $Player2]
var airship: PackedScene
var a: Airship

func _ready() -> void:
	for i: int in range(G.playerAlive.size()):
		if G.playerAlive[i]:
			airship = load("res://Player/Scenes/player_airship.tscn")
			a = airship.instantiate()
			a.currentPlayer = i
			a.add_to_group(str("airship(Player", a.currentPlayer, ")"))
			get_parent().call_deferred("add_child", a)
			a.global_position = marker[i].global_position
	queue_free()
