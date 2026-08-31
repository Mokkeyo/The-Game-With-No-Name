extends Menu
class_name RulesMenu

const MIN_TIME: int = 0
@export var max_time: int = 300

const MIN_HP: int = 1
@export var max_hp: int = 50

@onready var infinite_signe: Label = $Time/Infinite
@onready var time_number: Label = $Time/Number
@onready var hitpoints_number: Label = $Hitpoints/Number
@onready var weapons: Menu = $Weapons
@onready var time_button: ValueButton = %Time
@onready var hp_button: ValueButton = %Hitpoints


func _ready() -> void:
	super._ready()
	update_hp()
	update_time()
	weapons.exited.connect(weapons_exited)
	time_button.current_value = BattleData.time
	hp_button.current_value = BattleData.hp
	time_button.value_changed.connect(change_time)
	hp_button.value_changed.connect(change_hp)
	hp_button.update_ui()
	time_button.update_ui()

func change_hp(value: int) -> void:
	if not value == BattleData.hp:
		BattleData.hp = value
		update_hp()


func change_time(value: int) -> void:
	if not value == BattleData.time:
		BattleData.time = value
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


func _on_weapons_button_pressed() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	weapons.visible = true
	weapons.enter()
