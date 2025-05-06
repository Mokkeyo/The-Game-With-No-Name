extends Node
class_name FloorRotaterComponent

@export var body: CharacterBody2D
@export var sprite: AnimatedSprite2D

var tween: Tween

func update_rotation() -> void:
	if  not body.is_on_floor():
		if not sprite.rotation_degrees == 0:
			rotate_sprite(0)
		return
		
	var floor_normal: Vector2 = body.get_floor_normal()
		
	var target_rotation: float = rad_to_deg(atan2(floor_normal.y, floor_normal.x)) + 90
	if not int(sprite.rotation_degrees) == int(target_rotation):
		rotate_sprite(target_rotation)


func rotate_sprite(target_rotation: float) -> void:
	tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees", target_rotation, 0.1)
