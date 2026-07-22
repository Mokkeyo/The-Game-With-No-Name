extends Node
class_name PlayerCombat

signal enemy_hit(jump_power: float)

const SWORD_OFFSET_X: float = 10.0
const SWORD_OFFSET_Y: float = 13.5
const SWORD_BASE_Y: float = -10.0
const SWORD_ROTATION: float = -145.0
const SWORD_HAND_OFFSET: float = -4
const MANA_REGEN: int = 11
const MAX_MANA: int = 100
const MANA_COST: int = 33

@export var enemy_jump_power: int = 210
@export var mana_timer: Timer
@export var sound_player: SoundPlayer

@onready var shoot_comp: ShootComponent = $ShootComponent

var player_index: int = 0
var sword: Sword
var wand: Wand
var facing_x: int = 1

#region Setup
func setup(s: Sword, w: Wand) -> void:
	assert(s != null)
	assert(w != null)
	assert(mana_timer != null)
#	assert(sound_player != null)
	
	sword = s
	wand = w
	
	setup_sword()
	connect_signals()


func connect_signals() -> void:
	mana_timer.timeout.connect(_on_ManaTimer_timeout)
	if sword.hit_box:
		sword.hit_box.hit.connect(_on_enemy_hit)

#endregion

#region Sword
func setup_sword() -> void:
	sword.end_position.y = SWORD_BASE_Y
	sword.end_rotation = SWORD_ROTATION
	change_sword_direction(Vector2(1,0), 0)


func is_attacking() -> bool:
	return sword.state == sword.State.ATTACKING


func attack() -> void:
	sword.try_attack()


func change_sword_direction(facing_direction: Vector2, player_rotation: float = 0) -> void:
	if facing_direction != Vector2.ZERO:
		var new_x_position: float = facing_direction.x * SWORD_OFFSET_X
		sword.default_position.x = new_x_position
		
		var new_y_position: float = facing_direction.y * SWORD_OFFSET_Y + SWORD_BASE_Y
		sword.default_position.y = new_y_position
		
		sword.facing_direction = facing_direction.normalized()
	
	if facing_direction.x != 0:
		facing_x = int(facing_direction.x)
	
	if not is_attacking():
		sword.position.x = SWORD_HAND_OFFSET * facing_x
		
		sword.end_position.x = sword.position.x
		
		sword.end_rotation = SWORD_ROTATION * facing_x + player_rotation
		
		sword.rotation_degrees = sword.end_rotation
#endregion

#region Wand
func flip_wand(facing_direction: Vector2) -> void:
	if facing_direction != Vector2.ZERO:
		wand.flip(facing_direction.x < 0)


func cast() -> void:
	if not can_cast():
		return

#	sound_player.sound = "magic"
#	sound_player.play_sound()
	consume_mana()
	wand.attack()
	var def: SpiritballDefinition = shoot_comp.projectile as SpiritballDefinition
	def.direction = -1 if wand.sprite.flip_h == true else +1
	print(def.direction)
	shoot_comp.shoot()


func can_cast() -> bool:
	return (
		wand.can_swing
		and Save.player.mana[player_index] >= MANA_COST
	)

#endregion



#region Mana
func consume_mana() -> void:
	Save.player.mana[player_index] -= MANA_COST
	
	update_mana_ui()


func update_mana_ui() -> void:
	G.mana_value_changed.emit(
		player_index, 
		Save.player.mana[player_index]
	)
#endregion

#region Signal Callbacks
func _on_enemy_hit(_damage: int) -> void:
	enemy_hit.emit(enemy_jump_power)


func _on_ManaTimer_timeout() -> void:
	Save.player.mana[player_index] = min(
		Save.player.mana[player_index] + MANA_REGEN,
		MAX_MANA
	)
	
	update_mana_ui()
#endregion
