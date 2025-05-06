extends CharacterBody2D

const UP_VECTOR: Vector2 =  Vector2(0, -1)
var move: Vector2 = Vector2(SPEED, 0)

@onready var RayCastLeft: RayCast2D = $RayCastLeft
@onready var RayCastRight: RayCast2D = $RayCastRight
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthComp: healthComponent = $healthComponent
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
@onready var floorComp: FloorRotaterComponent = $FloorRotaterComponent


const GRAVITY: int = 100
const SPEED: int = 80
const JUMP_POWER: int = 80
var jump_x: int = 0
var direction: int = 1
var is_alive: bool = true

func _ready() -> void:
	animatedSprite.play("walk")
	healthComp.died.connect(die)
	resetComp.resetting_stats.connect(respawn)


func _physics_process(delta: float) -> void:
	if not is_alive:
		collision.disabled = true
		return
	
	floorComp.update_rotation()
	move.y += GRAVITY * delta

	if is_on_floor():
		if animatedSprite.animation == "air":
			on_landing()
		else:
			move.y = 0
			if is_on_wall() or is_over_abyss():
				turn()

	set_velocity(move)
	set_up_direction(UP_VECTOR)
	move_and_slide()


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


func die() -> void:
	is_alive = false
	animatedSprite.play("die")


func respawn() -> void:
	is_alive = true
	animatedSprite.play("walk")


func is_over_abyss() -> bool:
	if move.x < 0:
		RayCastLeft.force_raycast_update()
		return RayCastLeft.get_collider() == null
	else:
		RayCastRight.force_raycast_update()
		return RayCastRight.get_collider() == null


func jump() -> void:
	animatedSprite.play("air")
	move.y = -JUMP_POWER
	move.x = SPEED * direction * 1.2
	jump_x = floor(position.x)


func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
