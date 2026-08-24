extends Node
class_name PlayerAnimation

signal flip_changed(value: bool)

enum Anim {IDLE, WALK, JUMP, FALL, DEAD, DOOR}

const MAP: Array[String] = [
	"idle",
	"walk",
	"jump",
	"fall",
	"game_over",
	"door",
]

var player_number: int
var sprite: AnimatedSprite2D

func setup(player_value: int, sprite_value: AnimatedSprite2D) -> void:
	assert(sprite_value != null)
	assert(player_value >= 0 and player_value < 2)
	
	player_number = player_value
	sprite = sprite_value


func play(anim: Anim) -> void:
	assert(sprite != null)
	assert(anim >= 0 and anim < MAP.size())
	var animation: String = str(MAP[anim], "_", player_number)
	if not sprite.animation == animation:
		sprite.play(animation)


func rotation() -> float:
	return sprite.rotation_degrees

func flip(left: bool) -> void:
	assert(sprite != null)
	
	if sprite.flip_h == left:
		return
	sprite.flip_h = left
	flip_changed.emit(left)
