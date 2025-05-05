extends Resource
class_name saveStat

@export var levelNumber: int  = 1
@export var playerHp: Array[float] = [100, 100]
@export var playerMana: Array[int] = [99, 99]
@export var kristallCount: int = 0
@export var kristallCollected: Array[bool] = [false, false, false, false, false, false, false, false]
@export var checkpointPosition: Vector2 = Vector2(0, 0)
@export var checkpointActive: bool = false
@export var finished: Array[bool] = [false, false, false]
@export var door: Array[int] = []
@export var enemysDefeated: Array[String] = []
