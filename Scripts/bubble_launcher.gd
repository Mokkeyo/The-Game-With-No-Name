extends Node2D

@onready var area: Area2D = $Area2D
@onready var arrow: Array[Sprite2D] = [$Arrow, $Arrow2]

var player_body: Array[Player] = [null, null]
var player_position: Vector2

var direction: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
var direction_map: Dictionary = {
	"up": Vector2(0, -1),
	"down": Vector2(0, 1),
	"left": Vector2 (-1, 0),
	"right": Vector2(1, 0)
}

func _ready() -> void:
	player_position = global_position + Vector2(0, 11)

func _process(_delta: float) -> void:
	for i: int in range(arrow.size()):
		if player_body[i]:
			player_body[i].global_position = player_position
			if C.pressed(C.left, i):
				set_direction("left", i)
			elif C.pressed(C.right, i):
				set_direction("right", i)
			elif C.pressed(C.up, i):
				set_direction("up", i)
			elif C.pressed(C.down, i):
				set_direction("down", i)
			if not direction[i] == Vector2.ZERO:
				var angle: float = atan2(direction[i].normalized().y, direction[i].normalized().x) - atan2(-1, 0)
				arrow[i].rotation = angle

			if C.just_pressed(C.interact, i) or C.just_pressed(C.jump, i):
				shoot_bubble(i)


func set_direction(j: String, i: int) -> void:
	direction[i] = direction_map[j]
	if not arrow[i].visible:
		arrow[i].visible = true


func shoot_bubble(i: int) -> void:
	for body: Player in area.get_overlapping_bodies():
		if body.is_in_group("Player_%d" %i):
			arrow[i].visible = false
			player_body[i] = null
			body.freeze = false
			body.velocity.y = 0
			if not direction[i] == Vector2.ZERO:
				body.islaunching = true
				body.bubble_direction = direction[i]
			direction[i] = Vector2.ZERO


func _on_Area2D_body_entered(body: Player) -> void:
	var arrow_size: int = arrow.size()
	for i: int in range(arrow_size):
		if body.is_in_group("Player_%d" %i):
			body.global_position = player_position
			player_body[i] = body
			body.velocity.y = 0
			body.bubble_direction = Vector2.ZERO
			body.islaunching = false
			body.animatedSprite.play("air")
