extends CharacterBody2D

@onready var healthComp: healthComponent = $healthComponent
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hpBar: progressBar = $"HPbar(enemy)"
@onready var RayCastLeft: RayCast2D = $RayCastLeft
@onready var RayCastRight: RayCast2D = $RayCastRight
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
@onready var floorComp: FloorRotaterComponent = $FloorRotaterComponent

var knockback_on: bool = false

@export var health: float = 40
const UP_VECTOR: Vector2 =  Vector2(0, -1)
var move: Vector2 = Vector2(SPEED, 0)
var knockback: Vector2 = Vector2.ZERO

const GRAVITY: int = 100
const SPEED: int = 80
const JUMP_POWER: int = 80

var jump_x: int = 0
var direction: int = 1
var is_alive: bool = true

func _ready() -> void:
	animatedSprite.play("walk")
	healthComp.died.connect(die)
	healthComp.health = health
	healthComp.max_health = health
	resetComp.resetting_stats.connect(respawn)
	
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(0.785398)
	floor_constant_speed = true
	slide_on_ceiling = false

func _physics_process(delta: float) -> void:
	if not is_alive:
		collision.disabled = true
		hpBar.visible = false
		return
	
	floorComp.update_rotation()
	move.y += GRAVITY * delta
	
	var snap_value: int = 4 if is_on_floor() else 0
	
	if not floor_snap_length == snap_value:
		floor_snap_length = snap_value
	
	set_velocity(move)
	set_up_direction(UP_VECTOR)
	move_and_slide()

	if is_on_floor():
		if animatedSprite.animation == "air":
			on_landing()
		else:
			move.y = 0
			if is_on_wall() or is_over_abyss():
				jump()


func die() -> void:
	is_alive = false
	animatedSprite.play("die")


func on_landing() -> void:
	animatedSprite.play("walk")
	move.x /= 1.2
	move.x = SPEED * direction
	if floor(position.x) == jump_x:
		turn()


func turn() -> void:
	direction *= -1
	move.x = SPEED * direction
	animatedSprite.flip_h = not animatedSprite.flip_h


func is_over_abyss() -> bool:
	if move.x < 0:
		RayCastLeft.force_raycast_update()
		return RayCastLeft.get_collider() == null
	else:
		RayCastRight.force_raycast_update()
		return RayCastRight.get_collider() == null


func respawn() -> void:
	is_alive = true
	animatedSprite.play("walk")


func jump() -> void:
	animatedSprite.play("air")
	move.y = -JUMP_POWER
	move.x = SPEED * direction * 1.2
	jump_x = floor(position.x)


func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
