extends Node2D

@onready var rope_left: CollisionShape2D = $Ropes/CollisionShapeLeft
@onready var rope_right: CollisionShape2D = $Ropes/CollisionShapeRight
@onready var marker: CharacterBody2D = $FallingSpikeTrap
@onready var texture_left: Sprite2D = $GhostChain
@onready var texture_right: Sprite2D = $GhostChain2

var rope_l: SegmentShape2D
var rope_r: SegmentShape2D
var start_position_y: float

func _ready() -> void:
	rope_l = rope_left.shape.duplicate() as SegmentShape2D
	rope_r = rope_right.shape.duplicate() as SegmentShape2D
	
	rope_left.shape = rope_l
	rope_right.shape = rope_r
	
	start_position_y = texture_left.global_position.y

func _physics_process(_delta: float) -> void:
	var end_position: float = marker.global_position.y - start_position_y + 4    
	var stretch_margin: float = end_position / texture_left.texture.get_size().y
	
	texture_left.scale.y = stretch_margin
	texture_right.scale.y = stretch_margin
	
	var end_collision: float = marker.global_position.y - rope_left.global_position.y
	rope_l.b.y = end_collision
	rope_r.b.y = end_collision
