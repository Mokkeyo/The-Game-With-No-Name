extends Area2D

@onready var animationPlayer: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animationPlayer.play("activated" if global_position == Save.player.checkpointPosition else "deactivated")
	G.checkpoint_activated.connect(check_if_checkpoint_active)


func _on_Checkpoint_body_entered(body: Player) -> void:
	if not global_position == Save.player.checkpointPosition or not Save.player.checkpointActive:
		update_checkpoint()
		body.health_component.refill_health(40)


func check_if_checkpoint_active() -> void:
	if not global_position == Save.player.checkpointPosition:
		animationPlayer.play("deactivated")


func update_checkpoint() -> void:
	Save.player.checkpointActive = true
	Save.player.checkpointPosition = global_position
	G.checkpoint_activated.emit()
	animationPlayer.play("activated")
