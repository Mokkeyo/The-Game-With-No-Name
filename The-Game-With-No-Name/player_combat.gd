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

@export var indikator: Sprite2D
@export var shoot_comp: ShootComponent

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
	change_sword_direction(Vector2.RIGHT, 0)


func is_attacking() -> bool:
	return sword.state == sword.State.ATTACKING


func attack() -> void:
	sword.try_attack()


func change_sword_direction(facing_direction: Vector2, player_rotation: float = 0) -> void:
	if facing_direction == Vector2.ZERO:
		return
	
	indikator.rotation_degrees = rad_to_deg(facing_direction.angle())
	
	sword.default_position = Vector2(
		facing_direction.x * SWORD_OFFSET_X,
		facing_direction.y * SWORD_OFFSET_Y + SWORD_BASE_Y
	)
	
	sword.facing_direction = facing_direction.normalized()
	
	if facing_direction.x != 0:
		facing_x = int(facing_direction.x)
	
	if is_attacking():
		return
	
	sword.position.x = SWORD_HAND_OFFSET * facing_x
	sword.end_position.x = sword.position.x
	
	var rotation: float = SWORD_ROTATION * facing_x + player_rotation
	sword.end_rotation = rotation
	sword.rotation_degrees = rotation
#endregion

#region Wand
func flip_wand(facing_direction: Vector2) -> void:
	if facing_direction != Vector2.ZERO:
		wand.flip(facing_direction.x < 0)


func cast() -> void:
	if not can_cast():
		return
	
	AudioManager.play_sfx(Sounds.WAND_ATTACK, wand.global_position)
	consume_mana()
	wand.attack()
	
	var def: SpiritballDefinition = shoot_comp.projectile as SpiritballDefinition
	def.direction = -1 if wand.sprite.flip_h else 1
	shoot_comp.shoot()


func can_cast() -> bool:
	return (
		wand.can_swing
		and mana() >= MANA_COST
	)

#endregion



#region Mana
func mana() -> float:
	return Save.player.mana[player_index]

func consume_mana() -> void:
	Save.player.mana[player_index] -= MANA_COST
	update_mana_ui()


func update_mana_ui() -> void:
	G.mana_value_changed.emit(
		player_index, 
		mana()
	)
#endregion

#region Signal Callbacks
func _on_enemy_hit(_damage: int) -> void:
	enemy_hit.emit(enemy_jump_power)


func _on_ManaTimer_timeout() -> void:
	Save.player.mana[player_index] = min(
		mana() + MANA_REGEN,
		MAX_MANA
	)
	
	update_mana_ui()
#endregion
