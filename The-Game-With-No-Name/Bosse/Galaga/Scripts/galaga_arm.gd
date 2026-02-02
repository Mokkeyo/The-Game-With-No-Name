extends StaticBody2D
class_name bossArm

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_comp: ShootComponent = $Shoot
@onready var health_comp: HealthComponent = $healthComponent
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D

var is_alive: bool = true

func _ready() -> void:
	health_comp.died.connect(play_die)


func process(delta: float, airship: Airship) -> void:
	var direction: Vector2 = (airship.global_position - global_position)
	var angleTo: float = transform.x.angle_to(direction)
	var value: float = sign(angleTo) * min(delta * 5, abs(angleTo))
	rotate(value)


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
