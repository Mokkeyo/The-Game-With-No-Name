extends Node2D
class_name Sword

enum SwordState {IDLE, ATTACKING, COOLDOWN}

@export var player: int = 1
@export var sword_left: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_box: HitBox = $Sprite2D/Hitbox
@onready var visible_timer: Timer = $VisibleTimer
@onready var cooldown_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var combo_reset_timer: Timer = $ComboTimer
@onready var input_buffer_timer: Timer = $InputBufferTimer

const ROTATION_UP: int = 40
const ROTATION_DOWN: int = 140

var state: SwordState = SwordState.IDLE
var swing_down: bool = true

const MAX_COMBO: int = 3
const NORMAL_COOLDOWN: float = 0.2
const COMBO_COOLDOWN: float = 1
const COMBO_RESET_TIME:float =  0.6
const INPUT_BUFFER_TIME: float = 0.15

var attack_buffered: bool = false

var combo: int = 0

func _ready() -> void:
	visible = G.battle_mode and G.sword


func try_attack() -> void:
	if state == SwordState.IDLE:
		attack()
	else:
		buffer_attack()


func buffer_attack() -> void:
	attack_buffered = true
	input_buffer_timer.start(INPUT_BUFFER_TIME)


func attack() -> void:
	if not state == SwordState.IDLE:
		return
	
	state = SwordState.ATTACKING
	combo += 1
	visible = true
	
	combo_reset_timer.start(COMBO_RESET_TIME)
	visible_timer.start()
	cooldown_timer.start(COMBO_COOLDOWN if combo >= MAX_COMBO else NORMAL_COOLDOWN)
	SoundMusic.play_sound_effect("sword")
	
	play_swing_animation()
	swing_down = not swing_down


func play_swing_animation() -> void:
	var side: String = "Left" if sword_left else "Right"
	var dir: String = "Down" if swing_down else "Up"
	animation_player.play("Swing%s(%s)" % [side, dir])


func flip(direction: int) -> void:
	if not state == SwordState.IDLE:
		return
	hit_box.knockback = 10 * direction
	sword_left = direction < 0
	sprite.rotation = direction * ROTATION_UP if swing_down else direction * ROTATION_DOWN


func _on_AttackTimer_timeout() -> void:
	state = SwordState.IDLE
	
	if combo >= MAX_COMBO:
		combo = 0
	
	if attack_buffered:
		attack_buffered = false
		attack()


func _on_VisibleTimer_timeout() -> void:
	sprite.visible = false


func _on_combo_timer_timeout() -> void:
	if state == SwordState.IDLE:
		combo = 0


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if state == SwordState.ATTACKING:
		state = SwordState.COOLDOWN


func _on_input_buffer_timer_timeout() -> void:
	attack_buffered = false


func _on_attack_timer_timeout() -> void:
	pass # Replace with function body.
