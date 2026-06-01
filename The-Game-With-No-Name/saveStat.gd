extends Resource
class_name SaveStat

@export var version: int = 1

@export var levelNumber: int  = 1
@export var hp: Array[float] = [100, 100]
@export var mana: Array[float] = [99, 99]
@export var kristallCount: int = 0
@export var kristallCollected: Array[bool] = [false, false, false, false, false, false, false, false]
@export var checkpointPosition: Vector2 = Vector2(0, 0)
@export var checkpointActive: bool = false
@export var finished: Array[bool] = [false, false, false]
@export var door: Array[int] = []
@export var enemysDefeated: Array[String] = []

@export var dialog_flags: Dictionary = {}

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
		"enemysDefeated": enemysDefeated,
		"dialog_flags": dialog_flags
	}

func from_dict(data: Dictionary) -> void:
	levelNumber = data.get("levelNumber", 1)
	dialog_flags = data.get("dialog_flags", {})
	
	var arr: Array = data.get("hp", [100, 100])
	
	hp.clear()
	for v: Variant in arr:
		if v is float:
			hp.append(v)
		else:
			push_warning("couldnt convert to float -> hp")
	
	arr = data.get("mana", [100, 100])
	mana.clear()
	for v: Variant in arr:
		if v is float:
			mana.append(v)
		else:
			push_warning("couldnt convert to float -> mana")
	
	kristallCount = data.get("kristallCount", 0)
	
	
	arr = data.get("kristallCollected", [false, false, false, false, false, false, false])
	kristallCollected.clear()
	for v: Variant in arr:
		if v is bool:
			kristallCollected.append(v)
		else:
			push_warning("couldnt convert to bool -> kristallCollected")
	
	var pos: Dictionary = data.get("checkpointPosition", {"x": 0.0, "y": 0.0})
	checkpointPosition = Vector2(
		safe_float(pos.get("x")),
		safe_float(pos.get("y"))
	)
	checkpointActive = data.get("checkpointActive", false)
	
	arr = data.get("finished", [false, false, false])
	finished.clear()
	for v: Variant in arr:
		if v is bool:
			finished.append(v)
		else:
			push_warning("couldnt convert to bool -> finished")
	
	arr = data.get("door", [])
	door.clear()
	for v: Variant in arr:
		if v is float:
			door.append(v)
		else:
			push_warning("couldnt convert to float -> door")
	
	arr = data.get("enemysDefeated", [])
	enemysDefeated.clear()
	for v: Variant in arr:
		if v is String:
			enemysDefeated.append(v)
		else:
			push_warning("couldnt convert to String -> enemysDefeated")

func safe_float(value: Variant, default: float = 0.0) -> float:
	if value is float or value is int:
		return value
	push_warning("couldnt convert to float or int -> checkpointPosition")
	return default
