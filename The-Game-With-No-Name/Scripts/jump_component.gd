extends Node
class_name JumpComponent

@export var body: CharacterBody2D

func _ready() -> void:
	if body == null:
		body = get_parent()

func jump(JUMP_POWER: float) -> void:
	body.velocity.y -= JUMP_POWER

func jump_cut(max_jump: float) -> void:
	if body.velocity.y < max_jump:
		body.velocity.y = max_jump
