extends Resource
class_name SaveStat

@export var version: int = 1

@export var levelNumber: int  = 1
@export var hp: Array[float] = [100, 100]
@export var mana: Array[int] = [99, 99]
@export var kristallCount: int = 0
@export var kristallCollected: Array[bool] = [false, false, false, false, false, false, false, false]
@export var checkpointPosition: Vector2 = Vector2(0, 0)
@export var checkpointActive: bool = false
@export var finished: Array[bool] = [false, false, false]
@export var door: Array[int] = []
@export var enemysDefeated: Array[String] = []

func to_dict() -> Dictionary:
	return {
		"version": version,
		"levelNumber": levelNumber,
		"hp": hp,
		"mana": mana,
		"kristallCount": kristallCount,
		"kristallCollected": kristallCollected,
		"checkpointPosition": {
			"x": checkpointPosition.x,
			"y": checkpointPosition.y
		},
		"checkpointActive": checkpointActive,
		"finished": finished,
		"door": door,
		"enemysDefeated": enemysDefeated
	}

func from_dict(data: Dictionary) -> void:
	levelNumber = data.get("levelNumber", 1)
	hp = data.get("hp", [100, 100])
	mana = data.get("mana", [99, 99])
	kristallCount = data.get("kristallCount", 0)
	kristallCollected = data.get("kristallCollected", [])
	var pos: Dictionary[String, float] = data.get("checkpointPosition", {"x": 0, "y": 0})
	checkpointPosition = Vector2(pos["x"], pos["y"])
	checkpointActive = data.get("checkpointActive", false)
	finished = data.get("finished", [])
	door = data.get("door", [])
	enemysDefeated = data.get("enemysDefeated", [])
