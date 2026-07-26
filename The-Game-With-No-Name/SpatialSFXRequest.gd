extends RefCounted
class_name SpatialSFXRequest

var sound: SoundEffect
var stream: AudioStream
var position: Vector2

func _init(s: SoundEffect, st: AudioStream, p: Vector2) -> void:
	sound = s
	stream = st
	position = p
