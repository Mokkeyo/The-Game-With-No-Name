extends CharacterBody2D
class_name Player

signal flip_value_changed

@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var lava_water_detectorCollision: CollisionShape2D = $LavaWater_Detector/CollisionShape2D
@onready var health_component: HealthComponent = $healthComponent
@onready var rotater_component: FloorRotaterComponent = $FloorRotaterComponent

@onready var lava_water_detector: LavaWaterDetector = $LavaWater_Detector
@onready var sword: Sword = $Sword
@onready var wand: Wand = $Wand
@onready var grab_zone: GrabZone = $GrabZone
@onready var mana_timer: Timer = $Timer/ManaTimer
@onready var coyote_timer: Timer = $Timer/CoyoteTimer
@onready var jump_buffer_timer: Timer = $Timer/JumpBufferTimer
@onready var knockback_timer: Timer = $Timer/KnockbackTimer
@onready var hurtbox: HurtBox = $Hurtbox
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var hitbox: HitBox = $Hitbox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var reset_comp: EnemyResetComponent = $ResetComponent

@onready var movement: PlayerMovement = $PlayerMovement
@onready var animation: PlayerAnimation = $PlayerAnimation
@onready var combat: PlayerCombat = $PlayerCombat
@onready var input: PlayerInput = $PlayerInput

@onready var States: Dictionary = {
	"ground": $States/ground_state,
	"air": $States/air_state,
	"rope": $States/rope_state,
	"knockback": $States/knockback_state,
	"launch":$States/launch_state,
}
var current_state: PlayerState
var can_doublejump: bool = true

const MANA_COST: int = 33
const FOOTSTEP_FRAMES: Array[int] = [2, 4, 6]
const PUSH: int = 60

@export var current_player: int = 0

var is_alive: bool = true
var knockback: Vector2 = Vector2.ZERO
var bubble_direction: Vector2 = Vector2()
var freeze: bool = false
var buffered_jump: bool = false

var inputs: Dictionary[String, String] = {}


func _ready() -> void:
	_set_player_inputs()
	movement.setup(self, lava_water_detector)
	animation.setup(self, animated_sprite)
	combat.setup(sword, wand)
	input.setup(inputs)
	combat.enemy_hit.connect(_on_enemy_hit)
	_connect_signals()
	_configure_floor_settings()
	health_component.health = G.save_stat.playerHp[current_player]
	
	for s: PlayerState in States.values():
		s.player = self
	
	change_state("ground")

func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = States[state_name]
	current_state.enter()


func _set_player_inputs() -> void:
	inputs = {
		"up": "player%d_up" % int(current_player + 1),
		"down": "player%d_down" % int(current_player + 1),
		"left": "player%d_left" % int(current_player + 1),
		"right": "player%d_right" % int(current_player + 1),
		"jump": "player%d_jump" % int(current_player + 1),
		"interact": "player%d_interact" % int(current_player + 1),
		"attack": "player%d_attack" % int(current_player + 1),
		"wand": "player%d_wand" % int(current_player + 1)
	}


func _configure_floor_settings() -> void:
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(0.785398)
	floor_constant_speed = true
	slide_on_ceiling = false


func _connect_signals() -> void:
	health_component.value_changed.connect(_on_value_changed)
	health_component.died.connect(respawn)
	health_component.setKnockback.connect(do_knockback.bind(health_component.knockbackDuration, health_component.knockbackDirection))
	reset_comp.resetting_stats.connect(enable_player)
	lava_water_detector.water_entered.connect(play_water_sound)
	lava_water_detector.water_exited.connect(play_water_sound)
	hitbox.damaged_enemy.connect(jump.bind(movement.JUMP_POWER))

func _physics_process(delta: float) -> void:
	if not is_alive or freeze:
		return
	
	current_state.handle_input()
	current_state.physics_update(delta)
	move_and_slide()


func jump(power: float) -> void:
	velocity.y = 0
	velocity.y = -power
	SoundMusic.play_sound_effect("water" if lava_water_detector.inWater else "jump")


func handle_airship_entry() -> void:
	for object: Airship in hurtbox.get_overlapping_bodies():
		if object.is_in_group(str("airship_", current_player)):
			enter_airship(object)
			break


func enter_airship(object: Airship) -> void:
	hitbox_collision.disabled = true
	hurtbox_collision.disabled = true
	object.go_in(self)
	visible = false


func handle_collision() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var block: MovableBlock = collision.get_collider() as MovableBlock
		if block:
			block.apply_central_impulse(-collision.get_normal() * PUSH)


func do_knockback(dir: Vector2) -> void:
	knockback = dir
	change_state("knockback")


func _on_value_changed() -> void:
	G.save_stat.playerHp[current_player] = health_component.health
	G.health_value_changed.emit(current_player, health_component.health)


func _on_enemy_hit() -> void:
	movement.jump()
	can_doublejump = true


func next_to_wall() -> bool:return next_to_right_wall() or next_to_left_wall() or is_on_wall()
func next_to_right_wall() -> bool:return raycast_right.is_colliding()
func next_to_left_wall() -> bool: return raycast_left.is_colliding()


func change_mana_value() -> void:
	G.save_stat.playerMana[current_player] -=33
	G.mana_value_changed.emit(current_player, G.save_stat.playerMana[current_player])


func respawn() -> void:
	is_alive = false
	animated_sprite.play("game_over")


func enable_player() -> void:
	is_alive = true
	grab_zone.rope_part = null
	grab_zone.can_grab = true
	velocity = Vector2(0, 0)
	health_component.health = 100
	G.health_value_changed.emit(current_player, 100)
	G.mana_value_changed.emit(current_player, 100)


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "game_over":
		reset_comp.set_stats()
		G.player_died.emit(current_player)


func _on_ManaTimer_timeout() -> void:
	G.save_stat.playerMana[current_player] += 11
	G.mana_value_changed.emit(current_player, G.save_stat.playerMana[current_player])


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite.animation == animation.MAP[animation.Anim.WALK]:
		return
	
	if animated_sprite.frame in FOOTSTEP_FRAMES:
		SoundComp.play_footstep(global_position)


func play_water_sound() -> void:
	SoundComp.audio_player_start(global_position, SoundComp.sound_effect["enter_water"], 0.5)


func _on_JumpBufferTimer_timeout() -> void:
	buffered_jump = false
