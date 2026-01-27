extends Node
class_name PlayerCombat

signal enemy_hit(jump_power: float)

@export var enemy_jump_power: int = 210

var sword: Sword
var wand: Wand

func setup(s: Sword, w: Wand) -> void:
	sword = s
	wand = w
	if sword.hit_box:
		sword.hit_box.hit.connect(_on_enemy_hit)

func can_attack() -> bool:
	return sword.state == sword.SwordState.IDLE

func attack(direction: int) -> void:
	sword.flip(direction)
	sword.try_attack()

func can_cast() -> bool:
	return wand.can_swing

func cast(direction: int) -> void:
	wand.flip(direction)
	wand.attack()

func _on_enemy_hit(_damage: int) -> void:
	enemy_hit.emit(enemy_jump_power)
