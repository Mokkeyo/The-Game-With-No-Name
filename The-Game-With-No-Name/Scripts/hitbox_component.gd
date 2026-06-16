extends Area2D
class_name HitBox

signal hit(target: HurtBox, damage: int, knockback: float)
signal damaged_enemy

@export var dmg: int = 20
@export var knockback: float = 0
@export var damage_type: G.DamageType = G.DamageType.NORMAL

@export_category("continues damage")
@export var continues_damage: bool = false
@export var damage_interval: float = 0.2

var targets: Array[HurtBox] = []

@onready var damage_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(damage_timer)
	damage_timer.one_shot = false
	damage_timer.wait_time = damage_interval
	damage_timer.timeout.connect(_damage_targets)


func _on_area_entered(area: Area2D) -> void:
	if not area is HurtBox:
		return
	
	var hurtbox: HurtBox = area as HurtBox
	
	if not continues_damage:
		apply_damage(hurtbox)
		return
	
	if hurtbox not in targets:
		targets.append(hurtbox)
	
	if damage_timer.is_stopped():
		damage_timer.start()


func _on_area_exited(area: Area2D) -> void:
	if not continues_damage:
		return
	
	if area is HurtBox:
		targets.erase(area)
	
	if targets.is_empty():
		damage_timer.stop()


func _damage_targets() -> void:
	for hurtbox: HurtBox in targets:
		if is_instance_valid(hurtbox):
			apply_damage(hurtbox)


func apply_damage(hurtbox: HurtBox) -> void:
	damaged_enemy.emit()
	hurtbox.receive_hit(dmg, knockback, damage_type)
