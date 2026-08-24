extends StaticBody2D
class_name GalagaHead

var lasers: Array[Laser] = []
var warnings: Array[Warning] = []

@onready var bullet_markers: Array[Marker2D] = [$bullet_position, $bullet_position2]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_comp: HealthComponent = $healthComponent
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D

var is_alive: bool = true


func _ready() -> void:
	hurtbox_collision.disabled = true
	health_comp.died.connect(play_die)


func start_warning() -> void:
	for i: int in warnings.size():
		var p: Vector2
		p.x = bullet_markers[i].global_position.x - 2
		p.y = bullet_markers[i].global_position.y
		warnings[i].start_warning(p, rotation_degrees)


func stop_warning() -> void:
	for warning: Warning in warnings:
		warning.stop_warning()


func start_laser() -> void:
	for i: int in lasers.size():
		var p: Vector2
		p.x = bullet_markers[i].global_position.x - 2
		p.y = bullet_markers[i].global_position.y
		lasers[i].start_laser(p, rotation_degrees)


func stop_laser() -> void:
	for laser: Laser in lasers:
		laser.stop_laser()


func play_die() -> void:
	is_alive = false
	animated_sprite.scale = Vector2(4, 4)
	animated_sprite.play("die")


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "die":
		var lightOccluder: LightOccluder2D = $LightOccluder2D
		var collision: CollisionShape2D = $CollisionShape2D
		hurtbox_collision.disabled = true
		collision.disabled = true
		lightOccluder.queue_free()
		animated_sprite.visible = false
