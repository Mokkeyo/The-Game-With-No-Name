extends Menu

signal player_ready
var player_ready_count: int = 0
@export var arena_choose: Menu

func exit() -> void:
	super.exit()
	arena_choose.exit()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("player2_jump"):
		button_pressed(1)
	if Input.is_action_just_pressed("player1_jump"):
		button_pressed(0)


func button_pressed(player: int) -> void:
	if G.battle_ready[player]:
		return
	var ReadyLabel: Array[Label] = [$Ready1, $Ready2]
	ReadyLabel[player - 1].visible = true
	G.battle_ready[player] = true
	player_ready_count += 1
	if player_ready_count > 1:
		super.exit()
		G.battle_ready[0] = true
		visible = false
		arena_choose.enter()
