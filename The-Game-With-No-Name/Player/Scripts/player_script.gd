extends CharacterBody2D
class_name Player

signal flip_value_changed

@onready var hurtboxCollision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var HitboxCollision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var lavaWaterDetectorCollision: CollisionShape2D = $LavaWater_Detector/CollisionShape2D
@onready var HealthComponent: healthComponent = $healthComponent
@onready var rotaterComponent: FloorRotaterComponent = $FloorRotaterComponent

@onready var lavaWaterDetector: LavaWaterDetector = $LavaWater_Detector
@onready var sword: Sword = $Sword
@onready var wand: Wand = $Wand
@onready var grabZone: GrabZone = $GrabZone
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

@onready var States: Dictionary = {
	"ground": $States/ground_state,
	"air": $States/air_state,
	"rope": $States/rope_state,
	"knockback": $States/knockback_state,
	"launch":$States/launch_state,
}
var current_state: PlayerState

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
var knockback: Vector2 = Vector2.ZERO
var bubble_direction: Vector2 = Vector2()
var freeze: bool = false
var buffered_jump: bool = false

var player_strings: Dictionary[String, String] = {}

var inputs: Dictionary[String, String] = {}


func _ready() -> void:
	set_player_strings()
	set_player_inputs()
	connect_signals()
	configure_floor_settings()
	HealthComponent.health = G.save_stat.playerHp[currentPlayer]
	
	for s: PlayerState in States.values():
		s.player = self
	
	change_state("ground")

func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = States[state_name]
	current_state.enter()


func set_player_strings() -> void:
	player_strings = {
		"airship" : "airship_%d" % currentPlayer,
		"idle" : "idle_%d" % currentPlayer,
		"fall": "fall_%d" % currentPlayer,
		"door": "door_%d" % currentPlayer,
		"jump": "jump_%d" % currentPlayer,
		"walk": "walk_%d" % currentPlayer,
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
	HealthComponent.value_changed.connect(on_value_changed)
	HealthComponent.died.connect(respawn)
	Hitbox.damage_dealth.connect(jump_on_enemy.bind(JUMP_POWER))
	HealthComponent.setKnockback.connect(do_knockback.bind(HealthComponent.knockbackDuration, HealthComponent.knockbackDirection))
	resetComp.resetting_stats.connect(enable_player)
	lavaWaterDetector.water_entered.connect(play_water_sound)
	lavaWaterDetector.water_exited.connect(play_water_sound)

func _physics_process(delta: float) -> void:
	if not is_alive or freeze:
		return
	
	current_state.handle_input()
	current_state.physics_update(delta)
	move_and_slide()


func move_horizontal(dir: float) -> void:
	var speed: float = WATER_SPEED if lavaWaterDetector.inWater else SPEED
	velocity.x = move_toward(velocity.x, dir * speed, ACCELERATION)


func play_animation(anim: String) -> void:
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	if not animated_sprite.animation == player_strings[anim]:
		animated_sprite.play(player_strings[anim])


func apply_gravity(delta: float) -> void:
	var gravity: float = WATER_GRAVITY if lavaWaterDetector.inWater else GRAVITY
	velocity.y += gravity * delta


func jump(power: float) -> void:
	velocity.y = 0
	velocity.y = -power
	SoundMusic.play_sound_effect("water" if lavaWaterDetector.inWater else "jump")


func handle_airship_entry() -> void:
	for object: Airship in hurtBox.get_overlapping_bodies():
		if object.is_in_group(player_strings["airship"]):
			enter_airship(object)
			break


func enter_airship(object: Airship) -> void:
	HitboxCollision.disabled = true
	hurtboxCollision.disabled = true
	object.go_in(self)
	visible = false


func handle_collision() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var block: MovableBlock = collision.get_collider() as MovableBlock
		if block:
			block.apply_central_impulse(-collision.get_normal() * PUSH)


func do_walljump() -> void:
	can_doublejump = true
	SoundMusic.play_sound_effect("jump")
	var dir: float
	if next_to_left_wall():
		dir = 2.5
	elif next_to_right_wall():
		dir = -2.5
	else:
		return
	velocity =Vector2(dir * SPEED, -JUMP_POWER)


func do_knockback(dir: Vector2) -> void:
	knockback = dir
	change_state("knockback")


func die() -> void:
	change_state("dead")


func on_value_changed() -> void:
	G.save_stat.playerHp[currentPlayer] = HealthComponent.health
	G.health_value_changed.emit(currentPlayer, HealthComponent.health)


func jump_on_enemy(jump_power: float) -> void:
	jump(jump_power)
	if not can_doublejump:
		can_doublejump = true


func next_to_wall() -> bool:return next_to_right_wall() or next_to_left_wall() or is_on_wall()
func next_to_right_wall() -> bool:return rayCastRight.is_colliding()
func next_to_left_wall() -> bool: return rayCastLeft.is_colliding()


func change_mana_value() -> void:
	G.save_stat.playerMana[currentPlayer] -=33
	G.mana_value_changed.emit(currentPlayer, G.save_stat.playerMana[currentPlayer])


func respawn() -> void:
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	is_alive = false
	animated_sprite.play("game_over")


func flip_sprite(flip_h: bool) -> void:
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	if not animated_sprite.flip_h == flip_h:
		animated_sprite.flip_h = flip_h
		flip_value_changed.emit()

func enable_player() -> void:
	is_alive = true
	grabZone.rope_part = null
	grabZone.can_grab = true
	velocity = Vector2(0, 0)
	HealthComponent.health = 100
	G.health_value_changed.emit(currentPlayer, 100)
	G.mana_value_changed.emit(currentPlayer, 100)


func _on_AnimatedSprite_animation_finished() -> void:
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	if animated_sprite.animation == "game_over":
		resetComp.set_stats()
		G.player_died.emit(currentPlayer)


func _on_ManaTimer_timeout() -> void:
	G.save_stat.playerMana[currentPlayer] += 11
	G.mana_value_changed.emit(currentPlayer, G.save_stat.playerMana[currentPlayer])


func _on_animated_sprite_2d_frame_changed() -> void:
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	if not animated_sprite.animation == player_strings["walk"]:
		return
	
	if animated_sprite.frame == 2 or animated_sprite.frame == 4 or animated_sprite.frame == 6:
		SoundComp.play_footstep(global_position)


func play_water_sound() -> void:
	SoundComp.audio_player_start(global_position, SoundComp.sound_effect["enter_water"], 0.5)


func _on_JumpBufferTimer_timeout() -> void:
	buffered_jump = false
