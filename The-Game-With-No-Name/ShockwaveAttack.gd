extends BossAttack
class_name ShockwaveAttack

var radius: float = 180.0
var force: float  = 700.0
var stun_time: float = 0.3

func can_use() -> bool:
	var player: Player = boss.player_detector.focus_player
	
	if player == null:
		return false
	
	var distance: float = player.global_position.distance_to(boss.global_position)
	
	return distance < 120

func start() -> void:
#	boss.animation_player.play("Shockwave")
#	await boss.animation_player.animation_finished
	
	explode() 
	
	if should_do_followup():
		do_follow_up()
	
	finish()


func should_do_followup() -> bool:
	match boss.phase:
		boss.Phase.Phase_1:
			return randf() < 0.3
			
		boss.Phase.Phase_2:
			return randf() < 0.6
			
		boss.Phase.ENRAGED:
			return true
	
	return false


func do_follow_up() -> void:
	var possible: Array[BossAttack] = []
	
	await boss.get_tree().create_timer(1).timeout
	
	for attack: BossAttack in boss.attacks:
		if attack == self or attack == AxtAttack:
			continue
		
		if attack.can_use():
			possible.append(attack)
	
	if not possible.is_empty():
		var attack: BossAttack = possible.pick_random()
		boss.queue_attack(attack)


func explode() -> void:
	var player_1: Player = boss.player_detector.focus_player

	var player_2: Player = boss.player_detector.next_player
	
	if player_1:
		player_1.velocity += calculate_knockback(player_1)
	
	if player_2:
		player_2.velocity += calculate_knockback(player_2)


func calculate_knockback(player: Node2D) -> Vector2:
	var distance: float = player.global_position.distance_to(boss.global_position)
	
	if distance > radius:
		return Vector2.ZERO
	
	var dir: Vector2 = player.global_position - boss.global_position
	
	dir.y -= 20.4
	dir = dir.normalized()
	
	var strength: float = 1.2 - distance / radius
	
	var vel: Vector2 = dir * force * strength
	
	return vel
	
