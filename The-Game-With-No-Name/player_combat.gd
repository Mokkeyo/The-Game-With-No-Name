extends Node
class_name PlayerCombat

signal enemy_hit(jump_power: float)

@export var enemy_jump_power: int = 210
@export var mana_timer: Timer
@export var sound_player: SoundPlayer

const MANA_COST: int = 33

var spirit_ball_scene: PackedScene = preload("res://Scenes/spirit_ball.tscn")
var spirit_ball_pool: Array[SpiritBall] = []

var current_player: int = 0

var sword: Sword
var wand: Wand
var facing_x: float = 1
#var sword_attack_position: Vector2 = Vector2.ZERO
#var sword_rotation: float = -145

func setup(s: Sword, w: Wand) -> void:
	sword = s
	wand = w
	sword.end_position.y = -10
	sword.end_rotation = -145
	mana_timer.timeout.connect(_on_ManaTimer_timeout)
	change_sword_direction(Vector2(1,0), 0)
	if sword.hit_box:
		sword.hit_box.hit.connect(_on_enemy_hit)
	await get_tree().process_frame

	for i: int in 2:
		create_spirit_ball()

func create_spirit_ball() -> SpiritBall:
	var ball: SpiritBall = spirit_ball_scene.instantiate()
	
	G.level_viewport.add_child(ball)
	
	ball.died.connect(disable_ball)
	
	disable_ball(ball)
	
	spirit_ball_pool.append(ball)
	
	return ball


func get_ball() -> SpiritBall:
	for ball: SpiritBall in spirit_ball_pool:
		if not ball.visible:
			return ball
	
	return create_spirit_ball()


func activate_ball() -> void:
	var ball: SpiritBall = get_ball()
	ball.left = wand.sprite.flip_h
	ball.sprite.flip_h = ball.left
	ball.global_position = wand.marker.global_position
	
	ball.visible = true
	
	ball.set_process(true)
	ball.set_physics_process(true)
	
	if ball.hit_box:
		ball.hit_box.monitoring = true


func disable_ball(ball: SpiritBall) -> void:
	if not is_instance_valid(ball):
		push_warning("instance spiritball not valid")
		return
	
	ball.visible = false
	ball.time = ball.life_time
	ball.set_process(false)
	ball.set_physics_process(false)
	
	if ball.hit_box:
		ball.hit_box.monitoring = false
	
	ball.global_position = Vector2.ZERO


func can_cast() -> bool:
	return wand.can_swing


func cast() -> void:
#	wand.flip(direction)
	if Save.player.mana[current_player] >= MANA_COST and can_cast():
		sound_player.sound = "magic"
		sound_player.play_sound()
		change_mana_value()
		wand.attack()
		activate_ball()


func is_attacking() -> bool:
	return sword.state == sword.State.ATTACKING


func attack() -> void:
	sword.try_attack()


func change_sword_direction(facing_direction: Vector2, player_rotation: float = 0) -> void:
	if facing_direction != Vector2.ZERO:
		var new_x_position: float = facing_direction.x * 10
		sword.default_position.x = new_x_position
		
		var new_y_position: float = facing_direction.y * 13.5 - 10
		sword.default_position.y = new_y_position
		
		sword.facing_direction = facing_direction.normalized()
	
	if facing_direction.x != 0:
		facing_x = facing_direction.x
	
	if not is_attacking():
		sword.position.x = -4 * facing_x
		
		sword.end_position.x = sword.position.x
		
		sword.end_rotation = -145 * facing_x + player_rotation
		
		sword.rotation_degrees = sword.end_rotation


func flip_wand(facing_direction: Vector2) -> void:
	if facing_direction != Vector2.ZERO:
		wand.flip(facing_direction.x < 0)


func _on_enemy_hit(_damage: int) -> void:
	enemy_hit.emit(enemy_jump_power)


func change_mana_value() -> void:
	Save.player.mana[current_player] -=MANA_COST
	G.mana_value_changed.emit(current_player, Save.player.mana[current_player])


func _on_ManaTimer_timeout() -> void:
	Save.player.mana[current_player] += 11
	if Save.player.mana[current_player] > 99:
		Save.player.mana[current_player] = 99
	G.mana_value_changed.emit(current_player, Save.player.mana[current_player])
