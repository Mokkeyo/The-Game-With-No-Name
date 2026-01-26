extends Node
class_name healthComponent

signal value_changed
signal died
signal setKnockback

@onready var invisibilityTimer: Timer = $invisibilityTimer

@export_group("Stats")
@export var health: float = 20
@export var invisibiltyFrames: float = 0.5
@export var knockbackDirection: Vector2
@export var knockbackDuration: float = 0.1

@export_group("Components")
@export var hpBar: progressBar
@export var invisibilityComp: InvisibleFramesComp
@export var lavaDetector: LavaWaterDetector

var max_health: float

func _ready() -> void:
	max_health = health
	
	if lavaDetector:
		lavaDetector.lava_entered.connect(die)


func damage(dmg: int, knockback: float) -> void:
	if not invisibilityTimer.is_stopped() or health <= 0:
		return
	
	health -= dmg
	emit_signal("value_changed")
	
	if hpBar:
		hpBar.set_percent_value_int(float(health/max_health * 100))
	
	if health <=  0:
		emit_signal("died")
		return
	
	invisibilityTimer.start(invisibiltyFrames)
	
	if invisibilityComp:
		invisibilityComp.play_invible_frames(invisibiltyFrames)
	
	if not knockback == 0:
		knockbackDirection = Vector2(knockback, 3) * 90
		emit_signal("setKnockback")


func die() -> void:
	health = 0
	
	if invisibilityComp:
		invisibilityComp.reset_invisible_frames()
	
	
	if hpBar:
		hpBar.set_value_int(float(health/max_health * 100))
	
	emit_signal("died")
