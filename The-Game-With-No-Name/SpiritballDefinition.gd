extends ProjectileDefinition
class_name SpiritballDefinition

@export var lifetime: float

# -1 = Left 
# +1 = Right
var direction: int = -1

func _init() -> void:
	scene = preload("res://Scenes/spirit_ball.tscn")
