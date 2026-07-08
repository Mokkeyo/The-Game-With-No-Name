extends Menu

@export var rules: Menu
@export var main: BattleMenu

var random_arena: int
var max_arena: int = 6
@onready var arena_sprite: Sprite2D = $Arena_1/Arena
@onready var arena_label: Label = $Arena_1/Label
@onready var arrow_right: Sprite2D = $Arena_1/richtung_right
@onready var arrow_left: Sprite2D = $Arena_1/richtung_left
@onready var rules_timer: Timer = $Timer
@onready var arena_button: Button = $Arena_1
@onready var battle_ready_menu: Menu = $BattleReady


func _ready() -> void:
	super._ready()
	arrow_left.visible = (BattleData.arena == 1)
	rules.exited.connect(Callable(main, "change_menu").bind(self))
	battle_ready_menu.visible = not BattleData.ready[0]
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	random_arena = rng.randi_range(1, 6)
	G.last_number = random_arena
	if BattleData.ready[0] and BattleData.ready[1]:
		arena_button.grab_focus()


func enter() -> void:
	print(BattleData.ready)
	if BattleData.ready[0] and BattleData.ready[1]:
		super.enter()    
		return
	battle_ready_menu.visible = true
	battle_ready_menu.enter()


func _input(_event: InputEvent) -> void:
	var direction: int = int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left"))
	
	if direction == 0 or not rules_timer.is_stopped():
		return
		
	rules_timer.start()
	if (BattleData.arena < max_arena + 1 and direction == 1) or (BattleData.arena > 1 and direction == -1):
		BattleData.arena = BattleData.arena + direction
		arena_sprite.texture = load("res://Arena/Textures/arena_%d.png" % BattleData.arena)
		arena_label.text = "Arena %d" % BattleData.arena if not BattleData.arena == max_arena + 1 else "Random"
		if direction == 1:
			arrow_right.texture = load("res://Arena/Textures/arrow_pressed.png")
		else:
			arrow_left.texture = load("res://Arena/Textures/arrow_pressed.png")
	
		arrow_right.visible = not (BattleData.arena == max_arena + 1)
		arrow_left.visible = not (BattleData.arena == 1)


func _on_timer_timeout() -> void:
	arrow_right.texture = load("res://Arena/Textures/arrow_unpressed.png")
	arrow_left.texture = load("res://Arena/Textures/arrow_unpressed.png")


func _on_arena_1_pressed() -> void:
	if BattleData.arena == 7:
		if random_arena == G.last_number:
			random_arena = random_arena + 1
			if random_arena >= 7:
				random_arena = 1
			G.last_number = random_arena
		BattleData.arena = random_arena
		
	get_tree().change_scene_to_file("res://Arena/Battle.tscn")


func _on_to_rules_pressed() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	main.change_menu(rules)


func _on_arena_1_focus_entered() -> void:
	set_process_input(true)


func _on_arena_1_focus_exited() -> void:
	set_process_input(false)
