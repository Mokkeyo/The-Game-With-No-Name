extends CharacterBody2D
class_name Airship


@onready var marker: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $airship
@onready var animationPlayer: AnimationPlayer = $DamagePlayer
@onready var shootComp: ShootComponent = $Shoot
@onready var hurtbox: HurtBox = $Hurtbox
@onready var healthComp: HealthComponent = $healthComponent
@onready var wait_timer: Timer = $wait_timer
@onready var reset_comp: EnemyResetComponent = $ResetComponent
@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D

@export var currentPlayer: int = 1
var can_exit: bool = false
var player_node: Player = null
var is_in: bool = false 
var is_alive: bool = true

@export var hitpoints: int = 100
const SPEED: int = 180
const ACCELERATION: int = 40
const DECELERATION: int = 40

var inputs: Dictionary[String, String] = {}

func _ready() -> void:
	set_inputs()
	tree_exited.connect(enable_player)
	sprite.play(str("default_", currentPlayer))
	healthComp.died.connect(die)
	healthComp.value_changed.connect(on_value_changed)
	reset_comp.enabling_stats.connect(respawn)
	reset_comp.disabling_stats.connect(die)

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


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	if is_in:
		check_key_input()
	elif not is_on_floor():
		velocity.y += 200 * delta
	
	move_and_slide()


func on_value_changed() -> void:
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
	
	if Input.is_action_just_pressed(inputs["interact"]) and can_exit:
		player_node.global_position = global_position
		enable_player()

func die() -> void:
	sprite.play("die")
	is_alive = false


func enable_player() -> void:
	if not player_node:
		return
	
	player_node.reset_comp.enable_stats()
	set_player()


func set_player() -> void:
	if not player_node or remote_transform.remote_path.is_empty() or not is_in:
		return
	set_collision_layer_value(13, false)
	velocity = Vector2.ZERO
	G.health_value_changed.emit(currentPlayer, Save.player.hp[currentPlayer])
	is_in = false
	var temp_p: NodePath = remote_transform.remote_path
	remote_transform.remote_path = ""
	player_node.connect_camera(temp_p)
	sprite.z_index = 0
	player_node = null


func respawn() -> void:
	sprite.play(str("default_", currentPlayer))
	is_alive = true


func go_in(playerNode: Player) -> void:
	on_value_changed()
	set_collision_layer_value(13, true)
	player_node = playerNode
	playerNode.reset_comp.disable_stats()
	remote_transform.remote_path = playerNode.disconnect_camera()
	
	is_in = true
	sprite.z_index = 1


func _on_airship_animation_finished() -> void:
	if sprite.animation == "die" and is_in:
		G.player_died.emit(currentPlayer)
		player_node.reset_comp.disable_stats()
		set_player()
		is_in = false
		reset_comp.disable_stats()
		healthComp.health = healthComp.max_health


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("airship"):
		can_exit = true


func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("airship"):
		can_exit = false
