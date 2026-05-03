extends Node2D

enum State {ACTIVE, WARNING, VANISHED}
var state: State = State.ACTIVE

@export var cooldown: float = 0.7
@export var respawn_time: float = 4

@onready var static_body: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var area_body: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite: Sprite2D = $falling_plattform
@onready var vanished_sprite: Sprite2D = $"falling_plattform(vanished)"
@onready var area: Area2D = $Area2D
@onready var respawn_timer: Timer = $RespawnTimer
@onready var invisible_frames: InvisibleFramesComp = $InvisibleFramesComp


func _ready() -> void:
	invisible_frames.invisibility_stopped.connect(deactivate)


func _on_Area2D_body_entered(body: Player) -> void:
	if not state == State.ACTIVE:
		return
	
	if body.velocity.y >= 0 \
	and body.global_position.y < global_position.y + 10 \
	and (body.is_on_floor() or body.buffered_jump):
		state = State.WARNING
		invisible_frames.play_invible_frames(cooldown)


func deactivate() -> void:
	state = State.VANISHED
	change_sprite()
	respawn_timer.start(respawn_time)


func _on_respawn_timer_timeout() -> void:
	state = State.ACTIVE
	change_sprite()


func change_sprite() -> void:
	var is_active: bool = state == State.ACTIVE
	static_body.disabled = not is_active
	area_body.disabled = not is_active
	sprite.visible = is_active
	vanished_sprite.visible = not is_active
