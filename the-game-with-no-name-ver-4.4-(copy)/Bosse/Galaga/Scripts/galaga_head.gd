extends StaticBody2D
class_name Boss

@onready var marker: Array[Marker2D] = [$LaserPosition, $LaserPosition2]
@onready var bullet_marker: Array[Marker2D] = [$bullet_position, $bullet_position2]
@onready var shootComp: Array[ShootComponent] = [$Shoot, $Shoot2]

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthComp: healthComponent = $healthComponent
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
var laser: PackedScene = preload("res://Bosse/Galaga/Szene/laser.tscn")
var l: Node2D

var warning: PackedScene = preload("res://Bosse/Galaga/Szene/warning.tscn")
var w: Node2D

var is_alive: bool = true


func _ready() -> void:
	hurtbox_collision.disabled = true
	healthComp.died.connect(play_die)


func process(delta: float, airship: Airship) -> void:
	var direction: Vector2 = (airship.global_position - global_position)
	var angleTo: float = transform.x.angle_to(direction)
	var value: float = sign(angleTo) * min(delta * 5, abs(angleTo))
	rotate(value)


func Laser() -> void:
	for i: int in range(marker.size()):
		l = laser.instantiate()
		l.rotation = self.rotation
		l.global_position = marker[i].global_position
		get_parent().add_child(l)


func play_die() -> void:
	is_alive = false
	animatedSprite.scale = Vector2(4, 4)
	animatedSprite.play("die")


func Warning() -> void:
	for i: int in range(marker.size()):
		w = warning.instantiate()
		w.rotation = self.rotation
		w.global_position = marker[i].global_position
		get_parent().add_child(w)


func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		var lightOccluder: LightOccluder2D = $LightOccluder2D
		var collision: CollisionShape2D = $CollisionShape2D
		hurtbox_collision.disabled = true
		collision.disabled = true
		lightOccluder.queue_free()
		animatedSprite.visible = false
