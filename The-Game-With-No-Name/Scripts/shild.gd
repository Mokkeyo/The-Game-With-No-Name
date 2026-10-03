extends Node2D

@export var shildNumber: int = 0
@onready var dialog_loader: DialogLoader = $DialogueLoader
@onready var interact_area: InteractionArea = $NPCArea

func _ready() -> void:
	interact_area.interacted.connect(dialog_loader.action)

