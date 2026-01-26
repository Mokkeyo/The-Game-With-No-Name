extends Area2D

@onready var animationPlayer: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
#	var sound_player: SoundPlayer = $SoundPlayer
#	sound_player.play()
	animationPlayer.play("activated" if global_position == G.save_stat.checkpointPosition else "deactivated")
	G.checkpoint_activated.connect(check_if_checkpoint_active)


func _on_Checkpoint_body_entered(_body: Node2D) -> void:
	if not global_position == G.save_stat.checkpointPosition:
		update_checkpoint()


func check_if_checkpoint_active() -> void:
	if not global_position == G.save_stat.checkpointPosition and not animationPlayer.animation == "deactivated":
		animationPlayer.play("deactivated")


func update_checkpoint() -> void:
	G.save_stat.checkpointActive = true
	G.save_stat.checkpointPosition = global_position
	G.emit_signal("checkpoint_activated")
	animationPlayer.play("activated")
