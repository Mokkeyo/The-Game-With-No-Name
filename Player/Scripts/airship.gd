extends CharacterBody2D
class_name Airship

signal playerCountChanged
signal playerDied
signal gameOver

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
const SPEED: int = 160
const BACKWARD: int = 10


func _ready() -> void:
	respawn_position = global_position
	otherPlayer = 1 if (currentPlayer == 0) else 0
	healthComp.died.connect(die)
	healthComp.value_changed.connect(on_value_changed)
	reset_comp.resetting_stats.connect(respawn)
	reset_comp.setting_stats.connect(die)

func _physics_process(_delta: float) -> void:
	if not is_alive:
		return

	if is_in:
		if player_node.freeze:
			return
		check_key_input()
	
	move_and_slide()


func on_value_changed() -> void:
	G.airshipHeal[currentPlayer] = healthComp.health
	G.emit_signal("health_value_changed", currentPlayer, G.airshipHeal[currentPlayer])


func check_key_input() -> void:
	velocity.x = (int(C.pressed(C.right, currentPlayer)) - int(C.pressed(C.left, currentPlayer))) * SPEED + (int(C.pressed(C.left, currentPlayer)) * + BACKWARD)
	velocity.y = (int(C.pressed(C.down, currentPlayer)) - int(C.pressed(C.up, currentPlayer))) * SPEED
	if C.pressed(C.attack, currentPlayer) and wait_timer.is_stopped():
		wait_timer.start(0.5)
		shootComp.shoot_bullet()
	
	if C.just_pressed(C.spawn, otherPlayer) and G.player_can_respawn:
		_respawn_player_and_airship()


func die() -> void:
	sprite.play("die")
	is_alive = false


func set_player() -> void:
	remove_child(player_node)
	get_parent().add_child(player_node)
	player_node.global_position = global_position
	is_in = false
	velocity = Vector2(0, 0)


func respawn() -> void:
	sprite.play("default")
	is_alive = true
	global_position = respawn_position


func go_in(playerNode: Player) -> void:
	on_value_changed()
	G.airshipHeal[currentPlayer] = 100
	G.playerInAirship[currentPlayer] = true
	playerNode.get_parent().remove_child(playerNode)
	add_child(playerNode)
	playerNode.visible = false
	is_in = true
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

	G.playerAlive[otherPlayer] = true
	G.player_get_in = true
	G.playerInAirship[otherPlayer] = true


func _on_airship_animation_finished() -> void:
	if sprite.animation == "die":
		set_player()
		G.airshipHeal[currentPlayer] = 100
		if G.playerAlive[otherPlayer]:
			G.start_respawn_timer = true
			G.playerAlive[currentPlayer] = false
			G.player_can_respawn = false
			G.playerInAirship[currentPlayer] = false
			reset_comp.set_stats()
			player_node.resetComp.set_stats()
			G.emit_signal("player_count_changed")
		else:
			G.playerInAirship[currentPlayer] = false
			G.emit_signal("game_over")
		player_node = null
		G.emit_signal("player_died")
