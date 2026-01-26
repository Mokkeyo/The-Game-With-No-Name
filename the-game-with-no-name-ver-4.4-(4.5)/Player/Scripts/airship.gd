extends CharacterBody2D
class_name Airship

#signal playerCountChanged
#signal playerDied
#signal gameOver

@onready var marker: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $airship
@onready var animationPlayer: AnimationPlayer = $DamagePlayer
@onready var shootComp: ShootComponent = $Shoot
@onready var hurtbox: HurtBox = $Hurtbox
@onready var healthComp: healthComponent = $healthComponent
@onready var wait_timer: Timer = $wait_timer
@onready var reset_comp: EnemyResetComponent = $ResetComponent

@export var currentPlayer: int = 1
var otherPlayer: int
var respawn_position: Vector2
var is_in: bool = false 
var is_alive: bool = true
var player_node: Player = null

@export var hitpoints: int = 100
const SPEED: int = 180
const ACCELERATION: int = 40
const DECELERATION: int = 40

var inputs: Dictionary[String, String] = {}

func _ready() -> void:
	set_inputs()
	sprite.play(str("default_", currentPlayer))
	respawn_position = global_position
	otherPlayer = 1 if (currentPlayer == 0) else 0
	healthComp.died.connect(die)
	healthComp.value_changed.connect(on_value_changed)
	reset_comp.resetting_stats.connect(respawn)
	reset_comp.setting_stats.connect(die)

func set_inputs() -> void:
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

func _physics_process(_delta: float) -> void:
	if not is_alive:
		return

	if is_in:
		check_key_input()
	
	move_and_slide()


func on_value_changed() -> void:
	print("value changed")
	G.health_value_changed.emit(currentPlayer, healthComp.health)


func check_key_input() -> void:
	var input_vector: Vector2 = Vector2.ZERO

	if Input.is_action_pressed(inputs["up"]):
		input_vector.y -= 1
	if Input.is_action_pressed(inputs["down"]):
		input_vector.y += 1
	if Input.is_action_pressed(inputs["left"]):
		input_vector.x -= 1
	if Input.is_action_pressed(inputs["right"]):
		input_vector.x += 1

	if not input_vector == Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION)

	if Input.is_action_pressed(inputs["attack"]) and wait_timer.is_stopped():
		wait_timer.start(0.5)
		shootComp.shoot_bullet()
	
#	if C.just_pressed(C.spawn, otherPlayer) and G.player_can_respawn:
#		_respawn_player_and_airship()


func die() -> void:
	sprite.play("die")
	is_alive = false

func set_player() -> void:
	remove_child(player_node)
	get_parent().add_child(player_node)
	player_node.global_position = global_position
	is_in = false 
	player_node.freeze = false
	player_node.HitboxCollision.disabled = false
	velocity = Vector2(0, 0)


func respawn() -> void:
	sprite.play(str("default_", currentPlayer))
	is_alive = true
	global_position = respawn_position


func go_in(playerNode: Player) -> void:
	on_value_changed()
	playerNode.get_parent().remove_child(playerNode)
	add_child(playerNode)
# 	playerNode.visible = false
	is_in = true
	playerNode.freeze = true
	playerNode.position = Vector2(2,-5)
	player_node = playerNode
	sprite.z_index = 1


func _respawn_player_and_airship() -> void:
	var player: PackedScene = load("res://Player/Scene/player_%d.tscn" % (otherPlayer + 1))
	var p: Player = player.instantiate()
	var airship: PackedScene = load("res://Player/Scenes/airship_player_%d.tscn" % (otherPlayer + 1))
	var a: Airship = airship.instantiate()
	get_parent().add_child(p)
	get_parent().add_child(a)
	var pos: Vector2 = marker.global_position + Vector2(0, -3)
	p.global_position = pos
	a.global_position = pos



func _on_airship_animation_finished() -> void:
	if sprite.animation == "die" and is_in:
		G.player_died.emit(currentPlayer)
		set_player()
		is_in = false
		reset_comp.set_stats()
