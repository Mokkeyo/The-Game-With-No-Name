extends PlayerState
class_name KnockbackState

func enter() -> void:
	player.animation.play(player.animation.Anim.JUMP)
	player.movement.start_knockback(player.knockback)

func physics_update(delta: float) -> void:
	player.movement.update_knockback(delta)
	if not player.movement.in_knockback:
		player.change_state("air")
