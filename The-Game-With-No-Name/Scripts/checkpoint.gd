extends Area2D

@onready var animationPlayer: AnimatedSprite2D = $Checkpoint
@onready var sprite: Sprite2D = $Crystall/Checkpoint0002

func _ready() -> void:
	var crystal: Node2D = $Crystall
	animationPlayer.play("Activated" if global_position == Save.player.checkpointPosition else "Deactivated")
	sprite.frame = 0 if global_position == Save.player.checkpointPosition else 1
	G.checkpoint_activated.connect(check_if_checkpoint_active)
	var tween: Tween = create_tween()
	tween.set_loops()
	
	tween.tween_property(crystal, "position:y", crystal.position.y -4, 1.0)
	tween.tween_property(crystal, "position:y", crystal.position.y, 1.0)

func _on_Checkpoint_body_entered(body: Player) -> void:
	if not global_position == Save.player.checkpointPosition or not Save.player.checkpointActive:
		AudioManager.play_sfx(Sounds.CHECKPOINT_ACTIVATE, global_position)
		body.health_component.refill_health(40)
		update_checkpoint()


func check_if_checkpoint_active() -> void:
	if not global_position == Save.player.checkpointPosition:
		animationPlayer.play("Deactivated")
		sprite.frame = 1

func update_checkpoint() -> void:
	Save.player.checkpointActive = true
	Save.player.checkpointPosition = global_position
	G.checkpoint_activated.emit()
	animationPlayer.play("Activated")
	sprite.frame = 0
