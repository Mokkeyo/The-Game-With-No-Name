extends Node2D
class_name Sword

enum State {IDLE, ATTACKING, COMBO_WINDOW, COOLDOWN}
var state: State = State.IDLE

var facing_direction: Vector2 = Vector2.RIGHT

var tween: Tween

var buffered_attack: bool = false
var combo_count: int = 0

var default_rotation: float
var default_position: Vector2

var end_position: Vector2
var end_rotation: float

@onready var hit_box: HitBox = %Hitbox
@onready var buffer_timer: Timer = $BufferTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var combo_timer: Timer = $ComboTimer

@export var combo_window: float = 0.5
@export var cooldown: float = 0.5
@export var player: int = 1
@export var max_combo: int = 3


func _ready() -> void:
	default_rotation = rotation_degrees
	default_position = position
	
	hit_box.monitoring = false


func try_attack() -> void:
	match state:
		State.IDLE:
			_start_attack()
		State.ATTACKING:
			_buffer_attack()
		State.COMBO_WINDOW:
			_start_attack()
		State.COOLDOWN:
			pass

func _buffer_attack() -> void:
	buffered_attack = true
	buffer_timer.start()


func _start_attack() -> void:
	buffered_attack = false
	
	state = State.ATTACKING
	
	combo_count += 1
	
	match combo_count:
		1:
			attack_downslash()
		2:
			attack_risingslash()
		3:
			attack_thrust()
	
	
	combo_timer.stop()


func _finish_attack() -> void:
	if combo_count >= max_combo:
		enter_cooldown()
		return
	
	state = State.COMBO_WINDOW
	combo_timer.start(combo_window)
	
	if buffered_attack:
		buffered_attack = false
		
		combo_timer.stop()
		
		_start_attack()


func reset_stats() -> void:
	rotation_degrees = end_rotation
	position = end_position
	combo_count = 0


func enter_cooldown() -> void:
	state = State.COOLDOWN
	cooldown_timer.start(cooldown)
	reset_stats()


func reset_combo() -> void:
	state = State.IDLE
	buffered_attack = false
	reset_stats()


func attack_slash(start_angle: float, end_angle: float, slash_duration: float = 0.1, recovery_duration: float = 0.12) -> void:
	stop_attack_tween()
	
	position = default_position
	
	var base_angle: float = rad_to_deg(facing_direction.angle())
	
	if facing_direction.x < 0:
		var temp: float = start_angle
		start_angle = end_angle
		end_angle = temp
	
	start_angle += base_angle
	end_angle += base_angle
	
	rotation_degrees = start_angle
	
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "rotation_degrees", start_angle, 0.04)
	tween.tween_callback(enable_hitbox)
	
	tween.tween_property(self, "rotation_degrees", end_angle, slash_duration)
	tween.tween_callback(disable_hitbox)
	
	tween.tween_property(self, "rotation_degrees", end_angle, recovery_duration)
	tween.finished.connect(_finish_attack)


func attack_downslash() -> void:
	attack_slash(0, 180, 0.10)


func attack_risingslash() -> void:
	attack_slash(180, 0, 0.12)


func attack_thrust() -> void:
	stop_attack_tween()
	
	position = default_position
	
	var thrust_target: Vector2 = default_position + facing_direction * 8
	var pullback_target: Vector2 = default_position - facing_direction * 4
	
	var base_angle: float = rad_to_deg(facing_direction.angle())
	
	rotation_degrees = base_angle + 90
	
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(self, "position", pullback_target, 0.04)
	tween.tween_callback(enable_hitbox)
	
	tween.tween_property(self, "position", thrust_target, 0.08)
	tween.tween_callback(disable_hitbox)
	
	tween.tween_property(self, "position", default_position, 0.12)
	tween.parallel().tween_property(self, "rotation_degrees", base_angle, 0.12)
	
	tween.finished.connect(_finish_attack)


func enable_hitbox() -> void:
	hit_box.monitoring = true


func disable_hitbox() -> void:
	hit_box.monitoring = false


func stop_attack_tween() -> void:
	if tween:
		tween.kill()

func _on_cooldown_timer_timeout() -> void:
	state = State.IDLE

func _on_combo_timer_timeout() -> void:
	reset_combo()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	_finish_attack()


func _on_buffer_timer_timeout() -> void:
	buffered_attack = false
