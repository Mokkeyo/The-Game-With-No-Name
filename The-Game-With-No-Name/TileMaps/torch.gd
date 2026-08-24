extends AnimatedSprite2D

func _ready() -> void:
	play("default")
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	sprite.play("default")
