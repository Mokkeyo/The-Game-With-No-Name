extends Node
class_name PlayerAnimation

signal flip_changed(value: bool)

var player: Player
var sprite: AnimatedSprite2D

enum Anim {IDLE, WALK, JUMP, FALL, DEAD, DOOR}

const MAP: Dictionary[Anim, String] = {
	Anim.IDLE: "idle",
	Anim.WALK: "walk",
	Anim.JUMP: "jump",
	Anim.FALL: "fall",
	Anim.DEAD: "game_over",
	Anim.DOOR: "door",
}

func setup(p: Player, s: AnimatedSprite2D) -> void:
	player = p
	sprite = s


func play(anim: Anim) -> void:
	var animation: String = str(MAP[anim], "_", player.current_player)
	if not sprite.animation == animation:
		sprite.play(animation)


func flip(left: bool) -> void:
	flip_changed.emit(left)
	sprite.flip_h = left
