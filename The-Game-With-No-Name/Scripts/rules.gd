extends Menu
class_name RulesMenu

const MIN_TIME: int = 0
@export var max_time: int = 300

const MIN_HP: int = 1
@export var max_hp: int = 50

@onready var infinite_signe: Label = $Time/Infinite
@onready var time_number: Label = $Time/Number
@onready var hitpoints_number: Label = $Hitpoints/Number
@onready var rules_timer: Timer = $Timer
@onready var weapons: Menu = $Weapons

enum State {HP, TIME}
var state: State

func _ready() -> void:
	super._ready()
	update_hp()
	update_time()
	weapons.exited.connect(Callable(self, "weapons_exited"))

func _input(_event: InputEvent) -> void:
	var direction: int = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	
	if direction == 0 or not rules_timer.is_stopped():
		return
	
	rules_timer.start()
	
	match state:
		State.HP:
			change_hp(direction)
		
		State.TIME:
			change_time(direction * 10)


func change_hp(direction: int) -> void:
	var next: int = clamp(BattleData.hp + direction, MIN_HP, max_hp)
	
	if not next == BattleData.hp:
		BattleData.hp = next
		update_hp()


func change_time(direction: int) -> void:
	var next: int = clamp(BattleData.time + direction, MIN_TIME, max_time)
	
	if not next == BattleData.time:
		BattleData.time = next
		update_time()


func update_hp() -> void:
	hitpoints_number.text = str(BattleData.hp)

func update_time() -> void:
	infinite_signe.visible = BattleData.time == 0
	time_number.visible = not infinite_signe.visible
	
	if BattleData.time > 0:
		time_number.text = "%d sec" % BattleData.time


func weapons_exited() -> void:
	enter()
	weapons.visible = false


func _on_hitpoints_focus_entered() -> void:
	state = State.HP


func _on_time_focus_entered() -> void:
	state = State.TIME


func _on_weapons_button_pressed() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	weapons.visible = true
	weapons.enter()
