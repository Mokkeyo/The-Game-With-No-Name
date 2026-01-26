extends TileMapLayer

func _ready() -> void:
	SoundComp.tilemaps.push_back(self)
