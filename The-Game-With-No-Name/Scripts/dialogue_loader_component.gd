extends Node2D
class_name DialogLoader

@export_enum(D.kratos, D.rick, D.shild, D.kristall, D.bossDoor, D.houseDoor, D.buschi, D.graveStone, D.enemyGraveStone) var npc: String

@export var blackBox: bool = false
@export var options: bool = false
@export var npc_node: Npc
var player: Player

var speaker: String
var dialog: Array

func start_dialogue_no_check() -> void:
	speaker = D.dialogue[npc][D.speaker]
	dialog = D.dialogue[npc][D.dialog]
	start()

func start_dialogue(index: int) -> void:
	speaker = D.dialogue[npc][D.speaker][index]
	dialog = D.dialogue[npc][D.dialog][index]
	start()

func start() -> void:
	player.velocity.x = 0
	player.animation.play(player.animation.Anim.DOOR)
	player.freeze = true
	if npc_node == null:
		npc_node = get_parent()
	G.emit_signal("start_dialog", blackBox, options, speaker, dialog, npc_node)

func check_for_dialog_collected(index: int) -> void:
	check("%s%s" % [npc, index])

func check_for_dialog_collected_no_check() -> void:
	check(npc)

func check(string: String) -> void:
	if not Save.options.textboxCollected.has(string):
		Save.options.textboxCollected.append(string)
		Save.options.textboxCount += 1
		Save.save_options()
		G.check_if_chatter_unlocked()

func has_dialog(npcing:String, index: int) -> bool:
	if Save.options.textboxCollected.has("%s%d" % [npcing, index]):
		return true
	return false

func finish_dialogue() -> void:
	player.freeze = false
	player = null
