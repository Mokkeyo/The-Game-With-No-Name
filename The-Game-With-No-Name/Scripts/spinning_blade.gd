extends Path2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var soundPlayer: SoundPlayer = $SoundPlayer

func _ready() -> void:
	animationPlayer.play("default")
#	soundPlayer.play_sound()
