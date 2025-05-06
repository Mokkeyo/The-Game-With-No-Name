extends Node2D

@export_enum ("Left", "Right") var swing_direction: String
@export var Animation_Speed: int = 1
@export var Spikeball: bool = false


func _ready() -> void:
	var stachelKugel: Sprite2D = $Sprite2D/StachelKugel
	var hitBox: CollisionShape2D = $Sprite2D/StachelKugel/Hitbox/CollisionShape2D
	var animationPlayer: AnimationPlayer = $AnimationPlayer
	
	animationPlayer.play("Swing_" + swing_direction)
	stachelKugel.visible = Spikeball
	hitBox.disabled = not Spikeball
	animationPlayer.speed_scale = Animation_Speed
