extends CharacterBody2D
class_name pet

@export var stop_distance: float = 1.5

@onready var animatedSprite: AnimatedSprite2D = $ghost_dog

var playerNode: Player
var SPEED: int = 120
var player: int = 1
var follow_player: bool = true

func _ready() -> void:   
	animatedSprite.play("pet_%d" % player)
	playerNode.flip_value_changed.connect(Callable(self, "flip"))

func _process(_delta: float) -> void:
	if G.playerInAirship[player] or not G.playerAlive[player]:
		queue_free()
		return
		
	if not follow_player:
		velocity = Vector2(0, 0)
	else:
		var direction: Vector2 = playerNode.position - global_position
		var distance: float = direction.length()
		if distance > stop_distance:
			velocity = (playerNode.position - position).normalized() * SPEED
		else:
			follow_player = false

	move_and_slide()

func flip() -> void:
	var tween: Tween
	tween = create_tween()
	var x_position: float = 23 if playerNode.animatedSprite.flip_h else -23
	tween.finished.connect(Callable(self, "on_tween_finished"))
	tween.tween_property(animatedSprite, "position", Vector2(x_position, 0) , 0.5)

func on_tween_finished() -> void:
	animatedSprite.flip_h = playerNode.animatedSprite.flip_h

func _on_radius_area_body_exited(body: Player) -> void:
	if body == playerNode:
		follow_player = true
