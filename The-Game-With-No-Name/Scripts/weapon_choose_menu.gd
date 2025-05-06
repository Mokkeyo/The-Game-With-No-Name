extends Menu
class_name Weapons

@onready var jumpButton: Button = $JumpButton
@onready var wandButton: Button = $WandButton
@onready var swordButton: Button = $SwordButton
@onready var jumpNo: Sprite2D = $Jump/No
@onready var wandNo: Sprite2D = $Wand/No
@onready var swordNo: Sprite2D = $Sword/No

func _ready() -> void:
	super._ready()
	jumpButton.button_pressed = G.jump
	wandButton.button_pressed = G.wand
	swordButton.button_pressed = G.sword


func _on_JumpButton_toggled(button_pressed: bool) -> void:
	jumpNo.visible = not button_pressed
	G.jump = button_pressed


func _on_SwordButton_toggled(button_pressed: bool) -> void:
	swordNo.visible = not button_pressed
	G.sword = button_pressed


func _on_WandButton_toggled(button_pressed: bool) -> void:
	wandNo.visible = not button_pressed
	G.wand = button_pressed
