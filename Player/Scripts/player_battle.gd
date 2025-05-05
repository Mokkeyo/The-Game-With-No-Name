extends CharacterBody2D

signal healthValueChanged
signal manaValueChanged
signal playerCountChanged
signal playerDied

var bullet: PackedScene = preload("res://Scenes/spirit_ball.tscn")
var Pet: PackedScene = preload("res://Player/Scenes/ghost_pet.tscn")
var player: PackedScene
var tween: Tween

@onready var HealthComponent: healthComponent = $healthComponent
@onready var LavaWaterDetector: lavaWaterDetector = $LavaWater_Detector
@onready var sword: Sword = $Sword
@onready var wand: Wand = $Wand
@onready var GrabZone: grabZone = $GrabZone
@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var PointLight: PointLight2D = $PointLight2D
@onready var manaTimer: Timer = $Timer/ManaTimer
@onready var coyoteTimer: Timer = $Timer/CoyoteTimer
@onready var jumpBufferTimer: Timer = $Timer/JumpBufferTimer
@onready var knockbackTimer: Timer = $Timer/KnockbackTimer
@onready var hurtBox: HurtBox = $Hurtbox
@onready var grabZoneTimer: Timer = $GrabZone/Timer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var rayCastLeft: RayCast2D = $RayCastLeft
@onready var rayCastRight: RayCast2D = $RayCastRight
@onready var Hitbox: HitBox = $Hitbox

const PUSH: int = 60
const GRAVITY: int = 600
const SPEED: int = 120
const ACCELERATION: int = 20
const WATER_SPEED: int = 80
const WALL_JUMP: int = 400
const JUMP_POWER: int = 210
const WATER_JUMP: int = 100
const WATER_FLOOR_JUMP: int = 20
const DOUBLE_JUMP: int = 210
const UP_VECTOR: Vector2 = Vector2(0, -1)
const WATER_GRAVITY: int = 200

@export var otherPlayer: int = 2
@export var currentPlayer: int = 1

var can_doublejump: bool = false
var is_jumping: bool = false
var is_alive: bool = true
var knockback_on: bool = false
var knockback: Vector2 = Vector2.ZERO
var buffered_jump: bool = false
var bubble_direction: Vector2 = Vector2()
var freeze: bool = false
var islaunching: bool = false

func _ready() -> void:
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(0.785398)
	floor_snap_length = 4
	floor_constant_speed = true
	slide_on_ceiling = false
	
	HealthComponent.connect("value_changed", Callable(self, "on_value_changed"))
	HealthComponent.connect("died", Callable(self, "respawn"))
	Hitbox.connect("damage_dealth", Callable(self, "on_stomp"))
	HealthComponent.connect("setKnockback", Callable(self,"damage_knockback"))
	LavaWaterDetector.connect("lava_entred", Callable(HealthComponent,"die"))
	
	HealthComponent.health = G.SaveStat.playerHp[currentPlayer - 1]
	
	player = load("res://Player/Scenes/player_%d.tscn" % otherPlayer)
	
	if G.SaveStat.checkpointActive:
		global_position = G.SaveStat.checkpointPosition
	
	if HealthComponent.health <= 0:
		HealthComponent.health = 100
		G.SaveStat.playerHp[currentPlayer - 1] = 100

func _physics_process(delta: float) -> void:
	if !is_alive:
		return
	
	if G.playerAlive[currentPlayer - 1] == false:
		queue_free()

	if islaunching:
		if is_on_floor() or is_on_ceiling() or is_on_wall():
			islaunching = false
			freeze = false
			can_doublejump = true

	if LavaWaterDetector.inWaterElevator:
		velocity.y = -1 * 200

	if freeze:
		return

	if LavaWaterDetector.inWater == false:
		if velocity.y > 600:
			velocity.y = 600
	else:
		if velocity.y > 250:
			velocity.y = 250

	if sword.slow_down:
		velocity.x = 0

	if GrabZone.rope_part != null:
		global_position = GrabZone.rope_part.global_position

	if is_on_ceiling() or is_on_floor() or knockback_on:
		velocity.y = 0
	if is_on_floor():
		can_doublejump = true
	
	if G.SaveStat.playerMana[currentPlayer -1] < 99 and manaTimer.is_stopped():
		manaTimer.start(4.0)
	
	if GrabZone.rope_part == null and LavaWaterDetector.inWater == false:
		velocity.y += GRAVITY * delta
	elif LavaWaterDetector.inWater:
		velocity.y += WATER_GRAVITY * delta

	check_key_input()
	set_animation()

	if is_jumping and velocity.y >= 0:
		is_jumping = true

	if !knockback_on:
		set_velocity(velocity)
		set_up_direction(UP_VECTOR)
		
		if get_floor_normal().y == -1 or get_floor_normal().y == 0:
			tween = create_tween()
			tween.tween_property(AnimatedSprite, "rotation_degrees", 0, 0.1)
		elif get_floor_normal().y > - 1 and get_floor_normal().y < -0.5:
			if get_floor_normal().x < 1 and get_floor_normal().x > 0:
				tween = create_tween()
				tween.tween_property(AnimatedSprite, "rotation_degrees", 45, 0.1)
			elif get_floor_normal().x > -1 and get_floor_normal().x < 0:
				tween = create_tween()
				tween.tween_property(AnimatedSprite, "rotation_degrees", -45, 0.1)

	else:
		knockback = knockback.move_toward(Vector2.ZERO, -20 * delta)
		set_velocity(knockback)
		knockback = velocity
	
	var was_on_floor: bool = is_on_floor()
	move_and_slide()
	var just_left_ground: bool = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ground:
		coyoteTimer.start(0.15)
	

func check_key_input() -> void:
	if GrabZone.rope_part != null:
		if C.pressed(C.jump, currentPlayer):
			velocity.y = -JUMP_POWER
			SoundMusic.play_sound_effect("jump")
			is_jumping = true
			GrabZone.rope_part = null
			grabZoneTimer.start()

	var speed_limit: float = WATER_SPEED if LavaWaterDetector.inWater else SPEED
	
	var direction: int = (int(C.pressed(C.right, currentPlayer)) - int(C.pressed(C.left, currentPlayer)))
	if direction == 0:
		velocity.x = lerp(velocity.x, 0.0, 0.5)
		if is_on_floor() and is_alive and not AnimatedSprite.animation == "nothing(Ver2)":
			AnimatedSprite.play("nothing(Ver2)")
	else:
		if wand.sprite.flip_h == bool(direction > 0):
			wand.flip(direction) 
		if sword.sword_left == bool(direction > 0) and sword.can_flip:
			sword.flip(direction)
		velocity.x = min(velocity.x + ACCELERATION, speed_limit) if direction > 0 else max(velocity.x - ACCELERATION, -speed_limit)

	if C.pressed(C.jump, currentPlayer):
		buffered_jump = true
		jumpBufferTimer.start(0.15)
		if LavaWaterDetector.inWater:
			jump()
			if !is_on_floor():
				is_jumping = true
				velocity.y = -WATER_JUMP
				SoundMusic.play_sound_effect("water")

		if next_to_left_wall() and !is_on_floor() and LavaWaterDetector.inWater == false:
			knockback = Vector2(2.5,-3) * 65
			do_walljump(false)
			
		if next_to_right_wall() and !is_on_floor() and LavaWaterDetector.inWater == false:
			knockback = Vector2(-2.5,-3) * 65
			do_walljump(true)

		if can_doublejump and LavaWaterDetector.inWater == false and !next_to_right_wall() and !next_to_left_wall():
			if !is_on_floor() and coyoteTimer.is_stopped():
				velocity.y = -DOUBLE_JUMP
				SoundMusic.play_sound_effect("jump")
				can_doublejump = false

	if C.pressed(C.jump, currentPlayer) or buffered_jump:
		jump()

	if C.released(C.jump, currentPlayer):
		if LavaWaterDetector.inWater == false:
			jump_cut()
		
	if C.pressed(C.wand, currentPlayer):
		if wand.can_swing and G.SaveStat.playerMana[currentPlayer -1] >= 30:
			wand.attack()
			SoundMusic.play_sound_effect("magic")
			var w: Node2D = bullet.instantiate()
			get_parent().add_child(w)
			w.global_position = wand.marker.global_position
			change_mana_value()

	if C.pressed(C.attack, currentPlayer) and sword.can_swing:
		sword.attack()

func on_value_changed() -> void:
	G.SaveStat.playerHp[currentPlayer - 1] = HealthComponent.health
	animationPlayer.play("invisible_frames")
	emit_signal("healthValueChanged")

func set_animation() -> void:
	if !is_alive:
		return
	
	if !sword.sword_left:
		sword.position.x = 7
	else:
		sword.position.x = -9

	if velocity.x > 0:
		if is_on_floor():
			AnimatedSprite.play("walk(Ver2)")
		AnimatedSprite.flip_h = false
	elif velocity.x < 0:
		if is_on_floor():
			AnimatedSprite.play("walk(Ver2)")
		AnimatedSprite.flip_h = true

	if velocity.y < 0 and is_on_floor() == false:
		AnimatedSprite.play("jump(Ver2)")
	elif velocity.y > 0 and is_on_floor() == false:
		AnimatedSprite.play("air")

func on_stomp() -> void:
	can_doublejump = true
	is_jumping = true
	if LavaWaterDetector.inWater == false:
		velocity.y = -JUMP_POWER
		SoundMusic.play_sound_effect("jump")
	else:
		velocity.y = -WATER_JUMP
		SoundMusic.play_sound_effect("water")

func do_walljump(left: bool) -> void:
	can_doublejump = true
	is_jumping = true
	SoundMusic.play_sound_effect("jump")
	knockback_on = true
	knockbackTimer.start(0.25)
	AnimatedSprite.flip_h = left

func jump() -> void:
	if is_on_floor() or coyoteTimer.is_stopped() == false:
		can_doublejump = true
		is_jumping = true
		buffered_jump = false
		coyoteTimer.stop()
		if LavaWaterDetector.inWater == false:
			velocity.y = -JUMP_POWER
			SoundMusic.play_sound_effect("jump")
		else:
			velocity.y = -WATER_JUMP
			SoundMusic.play_sound_effect("water")

func jump_cut() -> void:
	if velocity.y < -100:
		velocity.y = -100

func next_to_wall() -> bool:
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall() -> bool:
	return rayCastRight.is_colliding()

func next_to_left_wall() -> bool:
	return rayCastLeft.is_colliding()

func change_mana_value() -> void:
	G.SaveStat.playerMana[currentPlayer -1] -=33
	emit_signal("manaValueChanged")

func respawn() -> void:
	is_alive = false
	G.SaveStatInf.deaths[G.path - 1] += 1
	G.save_options()
	G.SaveStat.playerHp[currentPlayer - 1] = 100
	G.SaveStat.playerMana[currentPlayer - 1] = 99
	AnimatedSprite.play("game_over")

func damage_knockback() -> void:
	var knockbackStrength: float = 60
	knockbackTimer.start(0.1)
	knockback_on = true
#	knockbackStrength = HealthComponent.knockbackStrength
	knockback = Vector2(knockbackStrength,-2) * 90

func _on_AnimatedSprite_animation_finished() -> void:
	if AnimatedSprite.animation == "game_over":
		G.SaveStat.playerMana[currentPlayer - 1] = 99
		queue_free()
		G.playerAlive[currentPlayer - 1] = false

func _on_damage_knockback_timeout() -> void:
	knockback_on = false

func _on_JumpBufferTimer_timeout() -> void:
	buffered_jump = false

func _on_ManaTimer_timeout() -> void:
	G.SaveStat.playerMana[currentPlayer -1] += 11
	emit_signal("manaValueChanged")
