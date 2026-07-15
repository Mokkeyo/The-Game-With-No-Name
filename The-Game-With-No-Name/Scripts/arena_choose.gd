extends Menu

@export var rules: Menu
@export var main: BattleMenu

var rolled_arena: int

var random_arena: int
var max_arena: int
var selected_arena: int = BattleData.arena

@onready var arena_sprite: Sprite2D = $Arena_1/Arena
@onready var arena_label: Label = $Arena_1/Label
@onready var arrow_right: Sprite2D = $Arena_1/richtung_right
@onready var arrow_left: Sprite2D = $Arena_1/richtung_left
@onready var rules_timer: Timer = $Timer
@onready var arena_button: Button = $Arena_1
@onready var battle_ready_menu: Menu = $BattleReady

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const ARROW_PRESSED: Texture2D = preload("res://Arena/Textures/arrow_pressed.png")
const ARROW_UNPRESSED: Texture2D = preload("res://Arena/Textures/arrow_unpressed.png")

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


func _ready() -> void:
	super._ready()
	
	var arena_size: int = ARENA_TEXTURES.size()
	max_arena = arena_size - 2
	random_arena = arena_size - 1
	
	rng.randomize()
	rolled_arena = rng.randi_range(1, max_arena)
	
	update_arena_ui()
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


func _input(_event: InputEvent) -> void:
	var direction: int = int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left"))
	
	if direction == 0 or not rules_timer.is_stopped():
		return
		
	rules_timer.start()
	
	var next: int = selected_arena + direction
	
	if next < 1 or next > random_arena:
		return
	
	selected_arena = next
	update_arena_ui()
	
	var arrow :Sprite2D = arrow_right if direction > 0 else arrow_left
	arrow.texture = ARROW_PRESSED


func players_ready() -> bool:
	return BattleData.ready[0] and BattleData.ready[1]


func update_arena_ui() -> void:
	arena_sprite.texture = ARENA_TEXTURES[selected_arena]
	arena_label.text = ("Random" if selected_arena == random_arena else "Arena %d" % selected_arena)
	
	arrow_right.visible = selected_arena < random_arena
	arrow_left.visible = selected_arena > 1

func _on_timer_timeout() -> void:
	for arrow: Sprite2D in [arrow_left, arrow_right]:
		arrow.texture = ARROW_UNPRESSED

func _on_arena_1_pressed() -> void:
	if selected_arena == random_arena:
		BattleData.arena = rolled_arena
	else:
		BattleData.arena = selected_arena
	
	get_tree().change_scene_to_file("res://Arena/Battle.tscn")


func _on_to_rules_pressed() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	main.change_menu(rules)


func _on_arena_1_focus_entered() -> void:
	set_process_input(true)


func _on_arena_1_focus_exited() -> void:
	set_process_input(false)
