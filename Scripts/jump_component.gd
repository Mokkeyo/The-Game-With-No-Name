extends Node
class_name JumpComponent

@export_group("Jump Stats")
@export var JUMP_POWER: int = 210
@export var WATER_JUMP: int = 100

@export_group("Components")
@export var body: CharacterBody2D
@export var waterDetector: LavaWaterDetector
@export var grabZone: GrabZone

var is_jumping: bool = false

var velocity: Vector2:
	get: return body.velocity
	set(value): body.velocity = value


func _ready() -> void:
	assert(body != null, "JumpComponent requires 'body' to be set.")


func jump(multiplikator: float) -> void:
	is_jumping = true
	
	if not waterDetector or not waterDetector.inWater:
		velocity.y = -JUMP_POWER * multiplikator
	else:
		velocity.y = -WATER_JUMP * multiplikator
	
	if grabZone or grabZone.rope_part:
		grabZone.rope_part = null
		grabZone.timer.start()

func jump_cut(max_velocity: float) -> void:
	if velocity.y < max_velocity:
		velocity.y = max_velocity
