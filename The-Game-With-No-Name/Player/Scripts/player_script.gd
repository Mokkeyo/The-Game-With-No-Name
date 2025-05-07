extends CharacterBody2D
class_name Player

signal flip_value_changed

const bullet: PackedScene = preload("res://Scenes/spirit_ball.tscn")
const Pet: PackedScene = preload("res://Player/Scenes/ghost_pet.tscn")
var player: Player
var tween: Tween

@onready var hurtboxCollision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var HitboxCollision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var lavaWaterDetectorCollision: CollisionShape2D = $LavaWater_Detector/CollisionShape2D
@onready var HealthComponent: healthComponent = $healthComponent
@onready var jumpComponent: JumpComponent = $JumpComponent
@onready var rotaterComponent: FloorRotaterComponent = $FloorRotaterComponent

@onready var lavaWaterDetector: LavaWaterDetector = $LavaWater_Detector
@onready var sword: Sword = $Sword
@onready var wand: Wand = $Wand
@onready var grabZone: GrabZone = $GrabZone
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var manaTimer: Timer = $Timer/ManaTimer
@onready var coyoteTimer: Timer = $Timer/CoyoteTimer
@onready var jumpBufferTimer: Timer = $Timer/JumpBufferTimer
@onready var knockbackTimer: Timer = $Timer/KnockbackTimer
@onready var hurtBox: HurtBox = $Hurtbox
@onready var grabZoneTimer: Timer = $GrabZone/Timer
@onready var rayCastLeft: RayCast2D = $RayCastLeft
@onready var rayCastRight: RayCast2D = $RayCastRight
@onready var Hitbox: HitBox = $Hitbox

@export var resetComp: EnemyResetComponent

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

@export var currentPlayer: int = 0
var otherPlayer: int

var can_doublejump: bool = false
var is_alive: bool = true
var knockback_on: bool = false
var knockback: Vector2 = Vector2.ZERO
var buffered_jump: bool = false
var bubble_direction: Vector2 = Vector2()
var freeze: bool = false
var islaunching: bool = false

var on_floor: bool
var on_ceiling: bool


func _ready() -> void:
	connect_signals()
	instantiate_pet()
	configure_floor_settings()
	otherPlayer = 1 if (currentPlayer == 0) else 0
	HealthComponent.health = G.SaveStat.playerHp[currentPlayer]

func instantiate_pet() -> void:
	var pe: pet = Pet.instantiate()
	pe.player = currentPlayer
	pe.playerNode = self
	get_parent().call_deferred("add_child", pe)
	pe.global_position = global_position + Vector2(-20, 0)


func configure_floor_settings() -> void:
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(0.785398)
	floor_constant_speed = true
	slide_on_ceiling = false


func connect_signals() -> void:
	HealthComponent.value_changed.connect(on_value_changed)
	HealthComponent.died.connect(respawn)
	Hitbox.damage_dealth.connect(jumpComponent.request_jump.bind(JUMP_POWER))
	HealthComponent.setKnockback.connect(do_knockback.bind(HealthComponent.knockbackDuration, HealthComponent.knockbackDirection))
	resetComp.resetting_stats.connect(enable_player)


func _physics_process(delta: float) -> void:
	if not is_alive or G.playerInAirship[currentPlayer]:
		return
	
	handle_launch()
	
	if freeze:
		return
	
	on_floor = is_on_floor()
	on_ceiling = is_on_ceiling()
	
	if lavaWaterDetector.inWaterElevator:
		velocity.y = -200
	   
	
	velocity.y = min(velocity.y, 250 if lavaWaterDetector.inWater else 600)
	
	if sword.slow_down:
		velocity.x = 0
	
	
	if grabZone.rope_part:
		global_position = grabZone.rope_part.global_position - Vector2(0, -4)
	elif not islaunching and not on_floor:
		apply_gravity(delta)
	
	if on_ceiling:
		jumpComponent.request_jump_cut()
	
	if (on_ceiling or is_on_wall()) and knockback_on:
		knockback_on = false
	
	if on_floor and not can_doublejump:
		can_doublejump = true
	
	floor_snap_length = 4 if on_floor else 0
	
	if G.SaveStat.playerMana[currentPlayer] < 99 and manaTimer.is_stopped():
		manaTimer.start(4.0)
	
	set_animation()
	check_key_input()
	rotaterComponent.update_rotation()
	handle_knockback(delta)
	handle_airship_entry()
	handle_collision()
	
	move_and_slide()
	
	var just_left_ground: bool = on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ground:
		coyoteTimer.start(0.15)


func handle_launch() -> void:
	if not islaunching:
		return
	
	if on_floor or on_ceiling or is_on_wall():
		islaunching = false
		freeze = false
		can_doublejump = true
		return
	
	velocity = bubble_direction * SPEED * 2


func handle_airship_entry() -> void:
	if not G.player_get_in:
		return
	
	for object: Airship in hurtBox.get_overlapping_bodies():
		if object.is_in_group("airship(Player%d)" % currentPlayer):
			enter_airship(object)
			G.player_get_in = false
			break


func enter_airship(object: Airship) -> void:
	HitboxCollision.disabled = true
	hurtboxCollision.disabled = true
	object.go_in(self)
	visible = false


func handle_collision() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision.get_collider() is MovableBlock:
			var rigid_collision: MovableBlock = collision.get_collider()
			rigid_collision.apply_central_impulse(-collision.get_normal() * PUSH)


func handle_knockback(delta: float) -> void:
	if knockback_on:
		knockback = knockback.move_toward(Vector2.ZERO, -20 * delta)
		set_velocity(knockback)
		return
	
	set_velocity(velocity)
	set_up_direction(UP_VECTOR)


func apply_gravity(delta: float) -> void:
	velocity.y += (WATER_GRAVITY if lavaWaterDetector.inWater else GRAVITY) * delta


func check_key_input() -> void:
	check_for_horizontal_movement()
	check_for_jumping()
	
	if C.just_pressed(C.interact, currentPlayer) and on_floor:
		handle_airship_entry()
	
	if C.just_pressed(C.wand, currentPlayer) and wand.can_swing and G.SaveStat.playerMana[currentPlayer] > 29:
		var w: SpiritBall = bullet.instantiate()
		w.left = wand.sprite.flip_h
		w.global_position = wand.marker.global_position
		wand.attack()
		SoundMusic.play_sound_effect("magic")
		get_parent().add_child(w)
		change_mana_value()
	
	if C.just_pressed(C.attack, currentPlayer) and sword.can_swing:
		sword.attack()


func check_for_horizontal_movement() -> void:
	if islaunching:
		return
	
	var speed_limit: float = WATER_SPEED if lavaWaterDetector.inWater else SPEED
	var direction: int = (int(C.pressed(C.right, currentPlayer)) - int(C.pressed(C.left, currentPlayer)))
	
	if direction == 0:
		velocity.x = lerp(velocity.x, 0.0, 0.5)
		if on_floor and not animatedSprite.animation == "nothing":
			animatedSprite.play("nothing")
		return
	
	velocity.x = min(velocity.x + ACCELERATION, speed_limit) if direction > 0 else max(velocity.x - ACCELERATION, -speed_limit)
	
	var facing_left: bool = direction > 0
	
	if wand.sprite.flip_h == facing_left:
		wand.flip(direction) 
		
	if sword.sword_left == facing_left and sword.can_flip:
		sword.flip(direction)


func check_for_jumping() -> void:
	if islaunching:
		return
	
	if buffered_jump and on_floor:
		jumpComponent.request_jump(JUMP_POWER)
		return
	
	if C.released(C.jump, currentPlayer) and not lavaWaterDetector.inWater:
		jumpComponent.request_jump_cut()
		return
	
	if C.just_pressed(C.jump, currentPlayer):
		buffered_jump = true
		jumpBufferTimer.start(0.15)
		
		if on_floor or not coyoteTimer.is_stopped() or lavaWaterDetector.inWater or grabZone.rope_part:
			jumpComponent.request_jump(JUMP_POWER)
			return
		
		if next_to_wall():
			var direction: int = (int(next_to_left_wall()) - int(next_to_right_wall()))
			do_walljump(false if direction == 1 else true, 0.25, Vector2(direction * 2.5,-3) * 65)
			return
		
		if can_doublejump and coyoteTimer.is_stopped():
			can_doublejump = false
			jumpComponent.request_jump(JUMP_POWER)


func jump() -> void:
	jumpComponent.request_jump(JUMP_POWER)
	buffered_jump = false
	coyoteTimer.stop()
	SoundMusic.play_sound_effect("water" if lavaWaterDetector.inWater else "jump")


func do_walljump(left: bool, knockbackDuration: float, knockbackDirection: Vector2) -> void:
	can_doublejump = true
	SoundMusic.play_sound_effect("jump")
	do_knockback(knockbackDuration, knockbackDirection)
	if not animatedSprite.flip_h == left:
		animatedSprite.flip_h = left
		emit_signal("flip_value_changed")


func do_knockback(knockbackDuration: float, knockbackDirection: Vector2) -> void:
	knockback = knockbackDirection
	knockback_on = true
	knockbackTimer.start(knockbackDuration)


func on_value_changed() -> void:
	G.SaveStat.playerHp[currentPlayer] = HealthComponent.health
	G.emit_signal("health_value_changed", currentPlayer, HealthComponent.health)


func set_animation() -> void:
	var falling: bool = velocity.y > 0 and not on_floor
	var jumping: bool = velocity.y < 0 and not on_floor
	
	if knockback_on:
		return
	
	if (islaunching or jumping) and not animatedSprite.animation == "jump":
		animatedSprite.play("jump")
	
	elif falling and not animatedSprite.animation == "air":
		animatedSprite.play("air")
	
	if velocity.x == 0:
		return
	
	if on_floor and not animatedSprite.animation == "walk": 
		animatedSprite.play("walk")
	
	var flip_sprite: bool = (false if velocity.x > 0 else true)
	var sword_position: int = (-9 if sword.sword_left else 7)
	
	if not sword.position.x == sword_position:
		sword.position.x = sword_position
	
	if not animatedSprite.flip_h == flip_sprite:
		animatedSprite.flip_h = flip_sprite
		emit_signal("flip_value_changed")


func next_to_wall() -> bool:return next_to_right_wall() or next_to_left_wall()
func next_to_right_wall() -> bool:return rayCastRight.is_colliding()
func next_to_left_wall() -> bool: return rayCastLeft.is_colliding()


func change_mana_value() -> void:
	G.SaveStat.playerMana[currentPlayer] -=33
	G.emit_signal("mana_value_changed", currentPlayer, G.SaveStat.playerMana[currentPlayer])


func respawn() -> void:
	is_alive = false
	G.SaveStatInf.deaths[G.path - 1] += 1
	G.save_options()
	G.SaveStat.playerHp[currentPlayer] = 0
	animatedSprite.play("game_over")


func enable_player() -> void:
	is_alive = true
	jumpComponent.request_jump_cut()
	islaunching = false
	grabZone.rope_part = null
	grabZone.can_grab = true
	velocity = Vector2(0, 0)
	G.playerAlive[currentPlayer] = true
	G.playerInAirship[currentPlayer] = false
	G.SaveStat.playerHp[currentPlayer] = 100
	G.SaveStat.playerMana[currentPlayer] = 99
	HealthComponent.health = 100
	G.emit_signal("health_value_changed", currentPlayer, 100)
	G.emit_signal("mana_value_changed", currentPlayer, 100)


func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "game_over":
		G.playerAlive[currentPlayer] = false
		resetComp.set_stats()
		G.emit_signal("player_died")


func _on_damage_knockback_timeout() -> void: knockback_on = false
func _on_JumpBufferTimer_timeout() -> void: buffered_jump = false


func _on_ManaTimer_timeout() -> void:
	G.SaveStat.playerMana[currentPlayer] += 11
	G.emit_signal("mana_value_changed", currentPlayer, G.SaveStat.playerMana[currentPlayer])
