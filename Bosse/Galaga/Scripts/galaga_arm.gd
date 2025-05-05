extends StaticBody2D
class_name bossArm

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shootComp: ShootComponent = $Shoot
@onready var healthComp: healthComponent = $healthComponent
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D

var is_alive: bool = true

func _ready() -> void:
	healthComp.died.connect(play_die)


func process(delta: float, airship: Airship) -> void:
	var direction: Vector2 = (airship.global_position - global_position)
	var angleTo: float = transform.x.angle_to(direction)
	var value: float = sign(angleTo) * min(delta * 5, abs(angleTo))
	rotate(value)


func play_die() -> void:
	is_alive = false
	animatedSprite.scale = Vector2(4, 4)
	animatedSprite.play("die")


func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		var lightOccluder: LightOccluder2D = $LightOccluder2D
		var collision: CollisionShape2D = $CollisionShape2D
		collision.disabled = true
		hurtbox_collision.disabled = true
		lightOccluder.queue_free()
		animatedSprite.visible = false
