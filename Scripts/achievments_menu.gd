extends Menu
class_name Achievments

var achievent_comp:AchievmentComponent = AchievmentComponent.new() 

@onready var timer: Timer = $Timer
@onready var achievements_panel: Control = $Advantments
@onready var ach_name_label: RichTextLabel = $TextBox/Name
@onready var description_label: RichTextLabel = $TextBox/Description
@onready var count_label: Label = $Count
@onready var chatter_ach_button: AchInfoButton = $Advantments/AdvButton1


func _ready() -> void:
	super._ready()
	exited.connect(timer.start)
	exited.connect(clear_text)
	
	for button: Button in achievements_panel.get_children():
		button.focus_entered.connect(change_text.bind(button))
		button.pressed.connect(change_text.bind(button))
		
		var icon: Sprite2D = button.get_child(0)
		icon.visible = G.SaveStatInf.achievments.has(icon.name)


func change_text(button: AchInfoButton) -> void:
	ach_name_label.text = " " + button.achievment_name
	description_label.text = (
		" Congrats. you got that achievement"
		if G.SaveStatInf.achievments.has(button.achievment_name)
		else " " + button.achievment_description
		)
	
	count_label.text = (
		str(G.SaveStatInf.textboxCount, " / ", G.max_text)
		if button == chatter_ach_button
		else ""
	)


func clear_text() -> void:
	ach_name_label.text = ""
	description_label.text = ""
	count_label.text = ""


func _on_back_button_focus_entered() -> void:
	clear_text()


func _on_timer_timeout() -> void:
	visible = false
