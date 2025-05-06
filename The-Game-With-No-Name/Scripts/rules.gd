extends Menu

@onready var infinite_signe: Label = $Time/Infinite
@onready var time_number: Label = $Time/Number
@onready var hitpoints_number: Label = $Hitpoints/Number
@onready var rules_timer: Timer = $Timer
@onready var weapons: Menu = $Weapons

enum State {change_hitpoints, change_time}
var state: State

func _ready() -> void:
	super._ready()
	var hitpoints: Label = $Hitpoints/Number
	var time: Label = $Time/Number
	hitpoints.text = str(G.battlePlayerHeal[0])
	time.text = str(G.battle_time)
	weapons.exited.connect(Callable(self, "weapons_exited"))

func _input(_event: InputEvent) -> void:
	var direction: int = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	
	if direction == 0 or not rules_timer.is_stopped():
		return
	
	rules_timer.start(0.1)
	
	match state:
		State.change_hitpoints:
			if (G.battlePlayerHeal[0] > 1 and direction == -1) or (G.battlePlayerHeal[0] < 50 and direction == 1):
				G.battlePlayerHeal[0] += direction 
				hitpoints_number.text = str(G.battlePlayerHeal[0])
		
		State.change_time:
			if (G.battle_time > 0 and direction == -1) or (G.battle_time < 300 and direction == 1):
				G.battle_time += direction * 10
				infinite_signe.visible = G.battle_time == 0
				time_number.visible = not infinite_signe.visible
				if time_number.visible:
					time_number.text = "%d sec" % G.battle_time


func weapons_exited() -> void:
	enter()
	weapons.visible = false


func _on_hitpoints_focus_entered() -> void:
	state = State.change_hitpoints


func _on_time_focus_entered() -> void:
	state = State.change_time


func _on_weapons_button_pressed() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	weapons.enter()
	weapons.visible = true
