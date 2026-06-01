extends CharacterBody2D
class_name Player_Online

signal flip_value_changed
var initialized: bool = false
const bullet: PackedScene = preload("res://Scenes/spirit_ball.tscn")

@onready var hurtboxCollision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var HitboxCollision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var lavaWaterDetectorCollision: CollisionShape2D = $LavaWater_Detector/CollisionShape2D
@onready var healthComponent: HealthComponent = $healthComponent
@onready var rotaterComponent: FloorRotaterComponent = $FloorRotaterComponent
@onready var camera: Camera2D = $Camera2D

@onready var lavaWaterDetector: LavaWaterDetector = $LavaWater_Detector
@onready var sword: Sword = $Sword
@onready var wand: Wand = $Wand
@onready var grabZone: GrabZone = $GrabZone
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var manaTimer: Timer = $Timer/ManaTimer
@onready var coyoteTimer: Timer = $Timer/CoyoteTimer
@onready var jumpBufferTimer: Timer = $Timer/JumpBufferTimer
@onready var knockbackTimer: Timer = $Timer/KnockbackTimer
@onready var hurtBox: HurtBox = $Hurtbox
@onready var grabZoneTimer: Timer = $GrabZone/Timer
@onready var rayCastLeft: RayCast2D = $RayCastLeft
@onready var rayCastRight: RayCast2D = $RayCastRight
@onready var Hitbox: HitBox = $Hitbox

@onready var resetComp: EnemyResetComponent = $ResetComponent

const PUSH: int = 60
const GRAVITY: int = 600
const SPEED: int = 120
const ACCELERATION: int = 20
const WATER_SPEED: int = 80
const JUMP_POWER: int = 210
const WATER_JUMP: int = 100
const WATER_FLOOR_JUMP: int = 70
const WATER_GRAVITY: int = 200

@export var currentPlayer: int = 0

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
var on_wall: bool
var in_water: bool

var player_strings: Dictionary[String, String] = {}

var inputs: Dictionary[String, String] = {}


func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	if not multiplayer.multiplayer_peer:
		return
	
	connect_signals()
	configure_floor_settings()
#	healthComponent.health = G.save_stat.playerHp[currentPlayer]

func set_player_strings() -> void:
	player_strings = {
		"airship" : "airship_%d" % currentPlayer,
		"idle" : "idle_%d" % currentPlayer,
		"fall": "fall_%d" % currentPlayer,
		"door": "door_%d" % currentPlayer,
		"jump": "jump_%d" % currentPlayer,
		"walk": "walk_%d" % currentPlayer,
		"game_over": "game_over"
	}


func set_player_inputs() -> void:
	inputs = {
		"up": "player%d_up" % int(currentPlayer + 1),
		"down": "player%d_down" % int(currentPlayer + 1),
		"left": "player%d_left" % int(currentPlayer + 1),
		"right": "player%d_right" % int(currentPlayer + 1),
		"jump": "player%d_jump" % int(currentPlayer + 1),
		"interact": "player%d_interact" % int(currentPlayer + 1),
		"attack": "player%d_attack" % int(currentPlayer + 1),
		"wand": "player%d_wand" % int(currentPlayer + 1)
	}


func configure_floor_settings() -> void:
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(0.785398)
	floor_constant_speed = true
	slide_on_ceiling = false


func connect_signals() -> void:
	healthComponent.value_changed.connect(on_value_changed)
	healthComponent.died.connect(respawn)
#	Hitbox.damage_dealth.connect(jump_on_enemy.bind(JUMP_POWER))
#	HealthComponent.setKnockback.connect(do_knockback.bind(HealthComponent.knockbackDuration, HealthComponent.knockbackDirection))
#	resetComp.resetting_stats.connect(enable_player)


func _physics_process(delta: float) -> void:
	if not multiplayer.multiplayer_peer:
		return
	
	if not is_multiplayer_authority():
		return
	
	if not initialized:
		return
	
	if not is_alive:
		return
	
	handle_launch()
	
	if freeze:
		return
	
	on_floor = is_on_floor()
	on_ceiling = is_on_ceiling()
	on_wall = is_on_wall()
	in_water = lavaWaterDetector.inWater
	
	if lavaWaterDetector.inWaterElevator:
		velocity.y = -200
	   
	
	velocity.y = min(velocity.y, 250 if in_water else 600)
	
#	if sword.slow_down:
#		velocity.x = 0
	
	
	if grabZone.rope_part:
		global_position = grabZone.rope_part.global_position - Vector2(0, -4)
	elif not islaunching and not on_floor:
		apply_gravity(delta)
	
	if (on_ceiling or on_wall) and knockback_on:
		knockback_on = false
	
	if on_floor and not can_doublejump:
		can_doublejump = true
	
#	if G.save_stat.playerMana[currentPlayer] < 99 and manaTimer.is_stopped():
#		manaTimer.start(4.0)
	
	set_animation()
	check_key_input()
	rotaterComponent.update_rotation()
	handle_knockback(delta)
	handle_airship_entry()
	handle_collision()
	
	var first_pos: float = global_position.y
	
	floor_snap_length = 15 if on_floor else 0
	
	move_and_slide()
	
	var last_pos: float = global_position.y
	
	on_floor = is_on_floor()
	
	var floor_normal: Vector2 = get_floor_normal()
	
	if on_floor and first_pos == last_pos and rad_to_deg(atan2(floor_normal.y, floor_normal.x)) + 90 == 0:
		if not position.y == round(position.y):
			position.y = round(position.y)
	
	var just_left_ground: bool = on_floor and not on_floor and velocity.y >= 0
	if just_left_ground:
		coyoteTimer.start(0.15)


func handle_launch() -> void:
	if not islaunching:
		return
	
	if on_floor or on_ceiling or on_wall:
		islaunching = false
		freeze = false
		can_doublejump = true
		return
	
	velocity = bubble_direction * SPEED * 2


func handle_airship_entry() -> void:
#	if not G.player_get_in:
#		return
	
	for object: Airship in hurtBox.get_overlapping_bodies():
		if object.is_in_group(player_strings["airship"]) and Input.is_action_just_pressed(inputs["interact"]):
			enter_airship(object)
#			G.player_get_in = false
			break


func enter_airship(_object: Airship) -> void:
	HitboxCollision.disabled = true
	hurtboxCollision.disabled = true
#	object.go_in(self)
	visible = false


func handle_collision() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var block: MovableBlock = collision.get_collider() as MovableBlock
		if block:
			block.apply_central_impulse(-collision.get_normal() * PUSH)


func handle_knockback(delta: float) -> void:
	if knockback_on:
		knockback = knockback.move_toward(Vector2.ZERO, -20 * delta)
		set_velocity(knockback)
		return
	
	set_velocity(velocity)


func apply_gravity(delta: float) -> void:
	velocity.y += (WATER_GRAVITY if in_water else GRAVITY) * delta


func check_key_input() -> void:
	check_for_horizontal_movement()
	check_for_jumping()
	
	if Input.is_action_just_pressed(inputs["interact"]) and on_floor:
		handle_airship_entry()
	
#	if Input.is_action_just_pressed(inputs["wand"]) and wand.can_swing and G.save_stat.playerMana[currentPlayer] > 29:
#		var w: SpiritBall = bullet.instantiate()
#		w.left = wand.sprite.flip_h
#		w.global_position = wand.marker.global_position
#		wand.attack()
#		SoundMusic.play_sound_effect("magic")
#		get_parent().add_child(w)
#		change_mana_value()
	
#	if Input.is_action_just_pressed(inputs["attack"]) and sword.can_swing:
#		sword.attack()


func check_for_horizontal_movement() -> void:
	if islaunching:
		return
	
	var speed_limit: float = WATER_SPEED if in_water else SPEED
	var direction: int = (int(Input.is_action_pressed(inputs["right"])) - int(Input.is_action_pressed(inputs["left"])))
	
	if direction == 0:
		velocity.x = lerp(velocity.x, 0.0, 0.5)
		if on_floor:
			rpc("play_animation", "idle")
		return
	
	velocity.x = min(velocity.x + ACCELERATION, speed_limit) if direction > 0 else max(velocity.x - ACCELERATION, -speed_limit)
	
	var facing_left: bool = direction > 0
	
	if wand.sprite.flip_h == facing_left:
		wand.flip(direction) 
		
#	if sword.sword_left == facing_left and sword.can_flip:
#		sword.flip(direction)


func check_for_jumping() -> void:
	if islaunching:
		return
	
	if buffered_jump and on_floor:
		jump(JUMP_POWER)
		return
	
	if Input.is_action_just_released(inputs["jump"]) and not in_water:
		jump_cut()
		return
	
	if Input.is_action_just_pressed(inputs["jump"]):
		buffered_jump = true
		jumpBufferTimer.start(0.15)
		
		if in_water:
			jump(WATER_JUMP if not on_floor else WATER_FLOOR_JUMP)
			return
		
		if grabZone.rope_part:
			grabZone.rope_part = null
#			grabZone.timer.start()
			jump(JUMP_POWER)
			return
		
		if on_floor or not coyoteTimer.is_stopped():
			jump(JUMP_POWER)
			return
		
		if next_to_wall():
			var direction: int = (int(next_to_left_wall()) - int(next_to_right_wall()))
			do_walljump(false if direction == 1 else true, 0.25, Vector2(direction * 2.5,-3) * 65)
			return
		
		if can_doublejump and coyoteTimer.is_stopped() and not on_floor:
			can_doublejump = false
			jump(JUMP_POWER)


func jump(jump_power: float) -> void:
	velocity.y = 0
	velocity.y -= jump_power
	buffered_jump = false
	coyoteTimer.stop()
#	SoundMusic.play_sound_effect("water" if in_water else "jump")

func jump_cut() -> void:
	if knockback_on:
		knockback_on = false
		return
	if velocity.y < -100:
		velocity.y = -100

func do_walljump(left: bool, knockbackDuration: float, knockbackDirection: Vector2) -> void:
	can_doublejump = true
#	SoundMusic.play_sound_effect("jump")
	do_knockback(knockbackDuration, knockbackDirection)
	rpc("flip_sprite", left)


func do_knockback(knockbackDuration: float, knockbackDirection: Vector2) -> void:
	knockback = knockbackDirection
	knockback_on = true
	knockbackTimer.start(knockbackDuration)


func on_value_changed() -> void:
#	G.save_stat.playerHp[currentPlayer] = healthComponent.health
	G.emit_signal("health_value_changed", currentPlayer, healthComponent.health)


func jump_on_enemy(jump_power: float) -> void:
	jump(jump_power)
	if not can_doublejump:
		can_doublejump = true


func set_animation() -> void:
	var falling: bool = velocity.y > 0 and not on_floor
	var jumping: bool = velocity.y < 0 and not on_floor
	
	if knockback_on:
		return
	
	if (islaunching or jumping):
		rpc("play_animation", "jump")
	
	elif falling:
		rpc("play_animation", "fall")
	
	if velocity.x == 0:
		return
	
	if on_floor: 
		rpc("play_animation", "walk")
	
#	var flip_h: bool = (false if velocity.x > 0 else true)
#	var sword_position: int = (-9 if sword.sword_left else 7)
	
#	if not sword.position.x == sword_position:
#		sword.position.x = sword_position
#		rpc("flip_sprite", flip_h)


func next_to_wall() -> bool:return next_to_right_wall() or next_to_left_wall()
func next_to_right_wall() -> bool:return rayCastRight.is_colliding()
func next_to_left_wall() -> bool: return rayCastLeft.is_colliding()


#func change_mana_value() -> void:
#	G.save_stat.playerMana[currentPlayer] -=33
#	G.emit_signal("mana_value_changed", currentPlayer, G.save_stat.playerMana[currentPlayer])


func respawn() -> void:
	is_alive = false
	rpc("play_animation", "game_over")

func enable_player() -> void:
	is_alive = true
	islaunching = false
	grabZone.rope_part = null
	grabZone.can_grab = true
	velocity = Vector2(0, 0)
	healthComponent.health = 100
	G.emit_signal("health_value_changed", currentPlayer, 100)
	G.emit_signal("mana_value_changed", currentPlayer, 100)


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "game_over":
#		resetComp.set_stats()
		G.emit_signal("player_died", currentPlayer)


func _on_damage_knockback_timeout() -> void: knockback_on = false
func _on_JumpBufferTimer_timeout() -> void: buffered_jump = false


#func _on_ManaTimer_timeout() -> void:
#	G.save_stat.playerMana[currentPlayer] += 11
#	G.emit_signal("mana_value_changed", currentPlayer, G.save_stat.playerMana[currentPlayer])


@rpc("call_local", "any_peer", "reliable")
func play_animation(anim: String) -> void:
	if not initialized:
		return
	
	if not animated_sprite.animation == anim:
		animated_sprite.play(player_strings[anim])


@rpc("call_local", "any_peer", "unreliable")
func flip_sprite(left: bool) -> void:
	if not initialized:
		return
	
	if not animated_sprite.flip_h == left:
		animated_sprite.flip_h = left
		emit_signal("flip_value_changed")


@rpc("call_remote", "any_peer", "unreliable")
func remote_init(pos: Vector2, cp: int) -> void:
	global_position = pos
	currentPlayer = cp
	
	set_player_strings()
	set_player_inputs()
	
	initialized = true
	
	if is_multiplayer_authority():
		camera.make_current()
