extends Node
class_name RespawnManager

@export var respawn_time: float = 2.0
signal respawn_requested(player: int)
signal cooldown

var timer: Timer = Timer.new()
var player_manager: PlayerManager
var respawnable_obj: Array[EnemyResetComponent]
var allow_respawn: bool = true

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)

func start() -> void:
	timer.start(respawn_time)

func _on_timeout() -> void:
	for i: int in player_size:
		if not player_alive[i]:
			player_label[i].visible = true
	
	var animation_player: AnimationPlayer = $AnimationPlayer
	animation_player.play("PlayerCanRespawn")
	set_process_unhandled_input(true)


func reset_objects() -> void:
	timer.stop()
	for obj: EnemyResetComponent in respawnable_obj:
			obj.reset_stats()


func game_over(player: int) -> void:
	pause.can_pause = false
	get_tree().paused = true
	await fader.fade_out().animation_finished
	restart_level(player)


func get_respawnable_objects() -> void:
	respawnable_obj = []
	for node: EnemyResetComponent in get_tree().get_nodes_in_group("respawnable"):
		respawnable_obj.append(node)


func _unhandled_input(_event: InputEvent) -> void:
	for i: int in player_size:
		if Input.is_action_just_pressed("player%d_spawn" % int(i + 1)) and not player_alive[i]:
			allow_respawn = false
			
			var player_position: Vector2 = in_game.player[1 - i].global_position
			player_alive[i] = true
			player_label[i].visible = false
			var player: Player = in_game.player[i]
			player.resetComp.reset_stats()
			player.global_position = player_position
			
			if player_spawner.airship_spawner:
				player_spawner.airship_spawner.set_airship_respawn_position(i, player_position)
				player.enter_airship(player_spawner.airship_spawner.airship[i])
			
			set_process_unhandled_input(false)
			in_game.set_viewport_size(player_alive)
			break
