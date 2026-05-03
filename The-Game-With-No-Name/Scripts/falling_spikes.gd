extends Sprite2D

var fall: bool = false
var spawn: Vector2

func _ready() -> void:
	spawn = global_position
	var hades: Hades = get_parent().find_child("Hades")
	hades.fall.connect(setFall)


func _process(delta: float) -> void:
	if !fall:
		global_position.y = spawn.y
	else:
		var move: Vector2 = Vector2(0, 1)
		global_position += move * 200 * delta

func setFall() -> void:
	fall = true

func _on_check_floor_body_entered(body: Node2D) -> void:
	if body.is_in_group("Floor"):
		fall = false
		global_position = spawn
