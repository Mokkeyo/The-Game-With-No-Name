extends Node2D
class_name statue

func _ready() -> void:
	var kristalls: Array[Sprite2D] = [$Kristall1, $Kristall2, $Kristall3]
	var allKristall:  Sprite2D = $KristallAll

	for i: int in range(kristalls.size()):
		if G.SaveStat.kristallCollected[i]:
			kristalls[i].visible = true

	allKristall.visible = G.SaveStat.kristallCount == 3
