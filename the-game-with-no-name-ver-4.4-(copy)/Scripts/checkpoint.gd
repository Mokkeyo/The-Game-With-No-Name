extends Area2D

@onready var animationPlayer: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animationPlayer.play("activated" if global_position == G.SaveStat.checkpointPosition else "deactivated")
	G.checkpoint_activated.connect(check_if_checkpoint_active)


func _on_Checkpoint_body_entered(_body: Node2D) -> void:
	if not global_position == G.SaveStat.checkpointPosition:
		update_checkpoint()


func check_if_checkpoint_active() -> void:
	if not global_position == G.SaveStat.checkpointPosition and not animationPlayer.animation == "deactivated":
		animationPlayer.play("deactivated")


func update_checkpoint() -> void:
	G.SaveStat.checkpointActive = true
	G.SaveStat.checkpointPosition = global_position
	G.SaveStat.door = G.tempDoor
	G.save_data()
	G.emit_signal("checkpoint_activated")
	animationPlayer.play("activated")
