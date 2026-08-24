extends Node2D

@onready var area: Area2D = $Area2D
@onready var arrow: Array[Sprite2D] = [$Arrow, $Arrow2]

var arrow_count: int

var player_bodies: Array[Player] = [null, null]
var player_position: Vector2

var direction: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]


func _ready() -> void:
	player_position = global_position + Vector2(0, 11)
	arrow_count = arrow.size()

func _physics_process(_delta: float) -> void:
	for i: int in range(arrow_count):
		var player: Player = player_bodies[i]
		if player == null:
			continue
		
		var dir: Vector2 = Vector2.ZERO
		
		if Input.is_action_pressed("player%d_left" % int(i + 1)):
			dir = Vector2 (-1, 0)
		elif Input.is_action_pressed("player%d_right" % int(i + 1)):
			dir = Vector2(1, 0)
		elif Input.is_action_pressed("player%d_up" % int(i + 1)):
			dir = Vector2(0, -1)
		elif Input.is_action_pressed("player%d_down" % int(i + 1)):
			dir = Vector2(0, 1)
		
		if not dir == Vector2.ZERO:
			set_direction(dir, i)
		
		var d: Vector2 = direction[i]
		
		if not d == Vector2.ZERO:
			arrow[i].rotation = atan2(d.y, d.x) + PI / 2.0
		
		
		if Input.is_action_just_pressed("player%d_interact" % int(i + 1)) or Input.is_action_just_pressed("player%d_jump" % int(i + 1)):
			shoot_bubble(i)


func set_direction(dir: Vector2, i: int) -> void:
	direction[i] = dir
	if not arrow[i].visible:
		arrow[i].visible = true


func shoot_bubble(i: int) -> void:
	for body: Player in area.get_overlapping_bodies():
		if body.is_in_group("Player_%d" %i):
			arrow[i].visible = false
			player_bodies[i] = null
			body.un_freeze()
			body.velocity = Vector2.ZERO
			if not direction[i] == Vector2.ZERO:
				body.state_machine.change_state(PlayerStates.ID.LAUNCH)
				body.launch_direction = direction[i]
			direction[i] = Vector2.ZERO
			break


func _on_Area2D_body_entered(body: Player) -> void:
	for i: int in range(arrow_count):
		if body.is_in_group("Player_%d" %i):
			player_bodies[i] = body
			body.velocity = Vector2.ZERO
			body.launch_direction = Vector2.ZERO
			body.freeze()
			body.animation.play(body.animation.Anim.JUMP)
			body.global_position = player_position
			break
