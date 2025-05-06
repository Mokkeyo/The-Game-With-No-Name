extends Node2D

@export var SPEED: int = 50
@onready var pathFollow: PathFollow2D = $Path2D/PathFollow2D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animationPlayer.play("default")
	
func _physics_process(delta: float) -> void:
	pathFollow.progress += SPEED * delta
