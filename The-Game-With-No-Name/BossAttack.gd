extends RefCounted
class_name BossAttack

var boss: Hades

var cooldown: float = 0
var last_used: float = -999

func _init(p_boss: Hades) -> void:
	boss = p_boss


func can_use() -> bool:
	return true

func start() -> void:
	pass

func update(_delta: float) -> void:
	pass

func finish() -> void:
	boss.finish_attack()
