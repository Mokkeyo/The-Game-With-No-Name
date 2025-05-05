extends CharacterBody2D

const GRAVITY: int = 100
const SPEED: int = 80
const JUMP_POWER: int = 80
const UP_VECTOR: Vector2 =  Vector2(0, -1)

var knockback_on: bool = false
var move: Vector2 = Vector2()
var jump_x: int = 0
var direction: int = 1
var knockback: Vector2 = Vector2.ZERO
var is_alive: bool = true

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hpBar: progressBar = $"HPbar(enemy)"
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var rayCastLeft: RayCast2D = $RayCastLeft
@onready var rayCastRight: RayCast2D = $RayCastRight
@onready var knockbackTimer: Timer = $Knockback_Timer

var start: bool = true
var start_moving: bool = false

@export var hitpoints: int = 100
var max_hitpoints: int = hitpoints



func _physics_process(delta: float) -> void:
	if is_alive == false:
		collision.disabled = true
		hpBar.visible = false
		return

	if knockback_on == true:
		move.y = 0

	move.y += GRAVITY * delta

	if !start_moving:
		move.x = 0
	elif start and !start_moving:
		move.x = SPEED
		start = false

	if is_on_floor():
		if animatedSprite.animation == "air":
			on_landing()
		else:
			move.y = 0
			if is_on_wall() or is_over_abyss():
				jump()

	if knockback_on == false:
		set_velocity(move)
		# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `Vector2(0, -1)`
		set_up_direction(UP_VECTOR)
		move_and_slide()

	if knockback_on == true:
		knockback= knockback.move_toward(Vector2.ZERO, 200 * delta)
		set_velocity(knockback)
		move_and_slide()
		knockback = velocity

func on_stomp() -> void:
	if knockbackTimer.is_stopped():
		hitpoints -= 50
		hpBar.set_percent_value_int(float(hitpoints)/max_hitpoints * 100)
		if hitpoints <= 0:
			animatedSprite.play("die")
			is_alive = false

func kl() -> void:
	if knockbackTimer.is_stopped():
		knockback_on = true
		knockback = Vector2(-1,-1) * 40
		knockbackTimer.start()

func kr() -> void:
	if knockbackTimer.is_stopped():
		knockback_on = true
		knockback = Vector2(1,-1) * 40
		knockbackTimer.start()

func on_landing() -> void:
	if start_moving:
		animatedSprite.play("walk")
		move.x /= 1.2
		move.x = SPEED * direction
		if floor(position.x) == jump_x:
			turn()

func turn() -> void:
	if start_moving:
		direction *= -1
		move.x = SPEED * direction
		animatedSprite.flip_h = not animatedSprite.flip_h

func is_over_abyss() -> bool:
	if start_moving:
		if move.x < 0:
			rayCastLeft.force_raycast_update()
			return rayCastLeft.get_collider() == null
		else:
			rayCastRight.force_raycast_update()
			return rayCastRight.get_collider() == null
	return false


func jump() -> void:
	if start_moving:
		animatedSprite.play("air")
		move.y = -JUMP_POWER
		move.x = SPEED * direction * 1.2
		jump_x = floor(position.x)


func _on_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		start_moving = true


func _on_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		start_moving = true
