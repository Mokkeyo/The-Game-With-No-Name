extends Npc

@export var shildNumber: int = 0

func _ready() -> void:
	dialogLoader.dialogue_start = str("s", shildNumber)
