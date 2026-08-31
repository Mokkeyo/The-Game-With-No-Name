extends Menu

@export var rules: Menu
@export var main: BattleMenu

var rolled_arena: int

var random_arena: int

@onready var arena_sprite: TextureRect = $ArenaButton/Arena
@onready var arena_label: Label = $ArenaButton/Label
@onready var arena_button: ValueButton = $ArenaButton
@onready var battle_ready_menu: Menu = $BattleReady

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const ARENA_TEXTURES: Array[Texture2D] = [
	null,
	preload("res://Arena/Textures/arena_1.png"),
	preload("res://Arena/Textures/arena_2.png"),
	preload("res://Arena/Textures/arena_3.png"),
	preload("res://Arena/Textures/arena_4.png"),
	preload("res://Arena/Textures/arena_5.png"),
	preload("res://Arena/Textures/arena_6.png"),
	preload("res://Arena/Textures/arena_7.png")
]

var direction: int = 0

func _ready() -> void:
	super._ready()
	
	var arena_size: int = ARENA_TEXTURES.size()
	random_arena = arena_size - 1

	arena_button.current_value = BattleData.arena
	arena_button.value_changed.connect(update_arena_ui)
	arena_button.update_ui()

	rng.randomize()
	rolled_arena = rng.randi_range(1, arena_button.max_value - 1)
	
	update_arena_ui(arena_button.current_value)
	rules.exited.connect(Callable(main, "change_menu").bind(self))
	battle_ready_menu.visible = not BattleData.ready[0]
	if players_ready():
		arena_button.grab_focus()


func enter() -> void:
	if players_ready():
		await get_tree().process_frame
		super.enter()    
		return
	battle_ready_menu.visible = true
	battle_ready_menu.enter()


func players_ready() -> bool:
	return BattleData.ready[0] and BattleData.ready[1]


func update_arena_ui(value: int) -> void:
	arena_sprite.texture = ARENA_TEXTURES[value]
	arena_label.text = ("Random" if value == random_arena else "Arena %d" % value)


func _on_arena_1_pressed() -> void:
	if arena_button.current_value == random_arena:
		BattleData.arena = rolled_arena
	else:
		BattleData.arena = arena_button.current_value
	
	get_tree().change_scene_to_file("res://Arena/battle.tscn")


func _on_to_rules_pressed() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	main.change_menu(rules)