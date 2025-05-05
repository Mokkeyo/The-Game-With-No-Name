extends Node2D
class_name DialogLoader

@export_enum(D.kratos, D.rick, D.shild, D.kristall, D.bossDoor, D.houseDoor, D.buschi, D.graveStone, D.enemyGraveStone) var npc: String

@export var blackBox: bool = false
@export var options: bool = false
var player: Player

func start_dialogue_no_check() -> void:
	G.speaker = D.dialogue[npc][D.speaker]
	G.dialog = D.dialogue[npc][D.dialog]
	start()

func start_dialogue(index: int) -> void:
	G.speaker = D.dialogue[npc][D.speaker][index]
	G.dialog = D.dialogue[npc][D.dialog][index]
	start()

func start() -> void:
	G.black_box = blackBox
	G.options = options
	player.velocity.x = 0
	player.animatedSprite.play("door")
	player.freeze = true
	G.emit_signal("start_dialog")

func check_for_dialog_collected(index: int) -> void:
	check("%s%s" % [npc, index])

func check_for_dialog_collected_no_check() -> void:
	check(npc)

func check(string: String) -> void:
	if not G.SaveStatInf.textboxCollected.has(string):
		G.SaveStatInf.textboxCollected.append(string)
		G.SaveStatInf.textboxCount += 1
		G.save_options()

func has_dialog(npcing:String, index: int) -> bool:
	if G.SaveStatInf.textboxCollected.has("%s%d" % [npcing, index]):
		return true
	return false

func finish_dialogue() -> void:
	player.freeze = false
	player = null
