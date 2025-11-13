extends Path2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animationPlayer.play("default")
