extends StaticBody2D
class_name GalagaArm

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_comp: HealthComponent = $healthComponent
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var marker: Marker2D = $Marker2D

var is_alive: bool = true

func _ready() -> void:
	health_comp.died.connect(play_die)


func play_die() -> void:
	is_alive = false
	animated_sprite.scale = Vector2(4, 4)
	animated_sprite.play("die")


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "die":
		var lightOccluder: LightOccluder2D = $LightOccluder2D
		var collision: CollisionShape2D = $CollisionShape2D
		collision.disabled = true
		hurtbox_collision.disabled = true
		lightOccluder.queue_free()
		animated_sprite.visible = false
