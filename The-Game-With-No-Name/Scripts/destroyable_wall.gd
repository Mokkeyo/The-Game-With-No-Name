extends StaticBody2D

func _ready() -> void:
	var health_comp: HealthComponent = $healthComponent
	health_comp.died.connect(die)

func die() -> void:
	var reset_comp: EnemyResetComponent = $ResetComponent
	reset_comp.call_deferred("set_stats")
