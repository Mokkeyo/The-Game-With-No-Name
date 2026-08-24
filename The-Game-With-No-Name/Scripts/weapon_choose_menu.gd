extends Menu
class_name Weapons

@onready var jump_button: Button = $JumpButton
@onready var wand_button: Button = $WandButton
@onready var sword_button: Button = $SwordButton
@onready var jump_no: Sprite2D = $Jump/No
@onready var wand_no: Sprite2D = $Wand/No
@onready var sword_no: Sprite2D = $Sword/No

func _ready() -> void:
	super._ready()
	jump_button.button_pressed = BattleData.jump
	wand_button.button_pressed = BattleData.wand
	sword_button.button_pressed = BattleData.sword


func _on_JumpButton_toggled(button_pressed: bool) -> void:
	jump_no.visible = not button_pressed
	BattleData.jump = button_pressed


func _on_SwordButton_toggled(button_pressed: bool) -> void:
	sword_no.visible = not button_pressed
	BattleData.sword = button_pressed


func _on_WandButton_toggled(button_pressed: bool) -> void:
	wand_no.visible = not button_pressed
	BattleData.wand = button_pressed
