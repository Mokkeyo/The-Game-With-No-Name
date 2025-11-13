@tool
extends Node2D
class_name SwingableRope

@export_enum ("Left", "Right") var swing_direction: String
@export_range(0, 360) var swing_angle: float = 50
@export var speed: float = 1.5

@export var Spikeball: bool = false

@export_range(1, 30) var rope_parts: int = 11:
	set = _set_rope_parts

@export_range(0, 30) var grip_parts_count: int = 11:
	set = _set_grip_parts

var rope_part: PackedScene = preload("uid://bkxvjvaobawtr")
var swing_tween: Tween
var swing_direction_sign: float = 1


func _ready() -> void:
	if not Engine.is_editor_hint():
		set_variables()
	


func update_spikeball() -> void:
	if not Engine.is_editor_hint():
		return
	
	var spikeball: Sprite2D = $StachelKugel
	var hitbox: CollisionShape2D = $StachelKugel/Hitbox/CollisionShape2D
	
	spikeball.visible = Spikeball
	hitbox.disabled = not Spikeball
	
	var ropeContainer: Node2D = $RopeContainer
	
	var children: Array[Node] = ropeContainer.get_children()
	var last_rope_part: Node2D = children[-1] if children.size() > 0 else null
	
	spikeball.position = last_rope_part.position


func update_chain() -> void:
	var ropeContainer: Node2D = $RopeContainer
	
	for i: int in range(ropeContainer.get_child_count()):
		ropeContainer.get_child(i).queue_free()
	
	for i: int in range(rope_parts):
		var r_p: RopePart = rope_part.instantiate()
		ropeContainer.add_child(r_p)
		r_p.position = Vector2(0, 3 + i * 6) 
	
	
		var col: CollisionShape2D = r_p.get_node("CollisionShape2D")
		var sprite: Sprite2D = r_p.get_node("Sprite2D")
		if i >= rope_parts - grip_parts_count:
			col.disabled = false
		else:
			col.disabled = true
			sprite.modulate = Color(0.393, 0.393, 0.393, 1.0)
	
	var spikeball: Sprite2D = get_node("StachelKugel")
	
	spikeball.visible = Spikeball
	spikeball.position = Vector2(0, rope_parts * 6 - 3)


func _set_grip_parts(value: int) -> void:
	grip_parts_count = clamp(value, 0, rope_parts)


func _set_rope_parts(value: int) -> void:
	rope_parts = value
	grip_parts_count = clamp(grip_parts_count, 0, rope_parts)



func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		return
	
	set_variables()


func set_variables() -> void:
	update_chain()
	update_spikeball()
	var hitbox: CollisionShape2D = $StachelKugel/Hitbox/CollisionShape2D
	hitbox.disabled = not Spikeball
	var swing_comp: SwingComponent = $swing_component
	swing_comp.swing_direction = swing_direction
	swing_comp.swing_angle = swing_angle
	swing_comp.speed = speed
	swing_comp.length = rope_parts * 6 - 3
