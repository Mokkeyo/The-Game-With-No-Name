extends CharacterBody2D
class_name Hades

signal fall

@onready var playerDetector: PlayerDetector = $PlayerDetector
@onready var sprite: Sprite2D = $"EndBoss(ver2)"
@onready var HealthComponent: healthComponent = $healthComponent
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var attack_cooldown_timer: Timer = $attack_cooldown_timer
@onready var achievmentComponent: AchievmentComponent = $achievmentComponent

@export var door_name: String
@export var damage_count: int = 20
@export var knockbackStrength: int = 60
const level_number: int = 5

const SPEED: int = 10
const GRAVITY: int = 280
const JUMP_POWER: int = 300

enum Attacks {AXT, SPEAR}
var weapon: Attacks = Attacks.AXT

var is_attacking: bool = true
var is_dashing: bool = false


func _ready() -> void:
	animationPlayer.play("Warning")
	attack_cooldown_timer.start()
	G.bossLabel = "Hades"
	G.maxBossHp = HealthComponent.max_health
	G.bossHp = HealthComponent.health
	attack_cooldown_timer.start()
	HealthComponent.died.connect(die)


func _physics_process(delta: float) -> void:
	set_velocity(velocity)
	set_up_direction(Vector2(0, -1))
	move_and_slide()
	
	velocity.y += GRAVITY * delta
	
	if is_on_wall() and is_dashing:
		is_dashing = false
		emit_signal("fall")
		reset_attack_state()
		
	if is_dashing:
		if sprite.flip_h:
			velocity.x += SPEED 
		else:
			velocity.x -= SPEED
		return
		
	velocity.x = 0
	
	if not is_attacking:
		sprite.flip_h = playerDetector.focus_player.global_position.x > global_position.x


func jump() -> void:
	velocity = Vector2(playerDetector.focus_player.global_position.x - global_position.x, -JUMP_POWER)
	global_position.x = playerDetector.focus_player.global_position.x


func die() -> void:
	G.next_level_door = door_name
	G.SaveStat.levelNumber = level_number
	G.emit_signal("enter_door")
	G.save_data()
	if G.SaveStatInf.deaths[G.path] == 0:
		achievmentComponent.add_achievment()

func Warning_finished() -> void:
	var choosed_weapon: String = "Axt" #default
	var distance_to_player: String = "Close" #default
	
	choosed_weapon = "Axt" if weapon == Attacks.AXT else "Spear"
	
	if weapon == Attacks.AXT:
		var close: bool = abs(playerDetector.focus_player.global_position.x - global_position.x) < 40
		distance_to_player = "Close" if close else "Far"
	
	weapon = Attacks.SPEAR if weapon == Attacks.AXT else Attacks.AXT
	
	var direction: String = "Right" if sprite.flip_h else "Left"
	var animation_name: String = choosed_weapon + "_" + distance_to_player + "_" + direction
	is_dashing = animation_name.begins_with("Spear_Close")
	if distance_to_player == "Far" and choosed_weapon == "Axt":
		jump()
	animationPlayer.play(choosed_weapon + "_" + distance_to_player + "_" + direction)



func _on_AxtTimer_timeout()-> void:
	var wave_component_left: WaveComponent = $wave_component_left
	var wave_component_right: WaveComponent = $wave_component_right
	var markerLeft: Marker2D = $MarkerLeft
	var markerRight: Marker2D = $MarkerRight
	
	var flip: bool = sprite.flip_h
	
	wave_component_left.wave_point = markerRight if flip else markerLeft
	wave_component_right.wave_point = markerRight if flip else markerLeft
	
	wave_component_left.shoot_wave()
	wave_component_right.shoot_wave()





func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Warning":
		Warning_finished()
	elif not is_dashing:
		reset_attack_state()


func reset_attack_state() -> void:
	attack_cooldown_timer.start()
	is_attacking = false
	playerDetector.changeTarget()


func _on_attack_cooldown_timer_timeout() -> void:
	animationPlayer.play("Warning")
