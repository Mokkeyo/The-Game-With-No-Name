extends Node
class_name SaveManager

const SAVE_DIR: String = "user://Save_Files/"

var active_slot: int = 0

var player: SaveStat = SaveStat.new()
var options: SaveStatInf = SaveStatInf.new()
var inputs: Dictionary = {}

func _ready() -> void:
	ensure_dir()


func delete_data(save_stat: int) -> void:
	var file_path: String = SAVE_DIR + "slot_" + str(save_stat) + ".json"
	if FileAccess.file_exists(file_path):
		var err: Error = DirAccess.remove_absolute(file_path)
		if not err == OK:
			push_error("Could not delete save files %s" % file_path)
	
	var temp_index: int = active_slot
	
	if temp_index < 0:
		return
	
	if temp_index < options.deaths.size():
		options.deaths[temp_index] = 0
	if temp_index < options.playerName.size():
		options.playerName[temp_index] = ""
	save_options()


func start_new_game(save_state: int) -> void:
	for i: int in player.kristallCollected.size():
		player.kristallCollected[i] = false
		
		if i < player.hp.size():
			player.hp[i] = 100
		if i < player.mana.size():
			player.mana[i] = 99
		if i < player.finished.size():
			player.finished[i] = false
	
	player.levelNumber = 1
	player.checkpointActive = false
	player.checkpointPosition = Vector2(0, 0)
	player.kristallCount = 0
	player.dialog_flags = {}
	if player.door:
		player.door.clear() 
	save_data(save_state)

#-------------------
#SAVE
#-------------------

#func save_all() -> void:
#	save_data()
#	save_options()
#	save_inputs()

func save_data(save_state: int) -> void:
	var path: String = SAVE_DIR + "slot_" + str(save_state) + ".json"
	save_json(path, player.to_dict())

func save_options() -> void:
	var path: String = SAVE_DIR + "options.json"
	save_json(path, options.to_dict())

func save_inputs() -> void:
	var path: String = SAVE_DIR  +  "inputs.json"
	var i_data: Dictionary = inputs
	save_json(path, i_data)

#-------------------
#LOAD
#-------------------

#func load_all() -> void:
#	load_data()
#	load_options()
#	load_inputs()


func load_data(save_state: int) -> void:
	var path: String = SAVE_DIR + "slot_" + str(active_slot) + ".json"
	var a_data: Dictionary = load_json(path)
	
	if a_data.is_empty():
		push_warning("Save file is missing or invalid -> slot_" + str(active_slot))
		save_data(save_state)
		return
	
	player.from_dict(a_data)


func load_options() -> void:
	var path: String = SAVE_DIR + "options.json"
	var o_data: Dictionary = load_json(path)

	if o_data.is_empty():
		push_warning("Options missing -> fallback to defaults")
		save_options()
		return
	
	options.from_dict(o_data)


func load_inputs() -> void:
	var path: String = SAVE_DIR + "inputs.json"
	var i_data: Dictionary = load_json(path)
	
	if i_data.is_empty():
		push_warning("Inputs missing -> fallback to defaults")
		apply_default_inputs()
		
		inputs = InputSerializer.inputmap_to_dict(InputMap.get_actions())
		save_inputs()
		return
	
	if not validate_input_data(i_data):
		push_warning("Invalid inputdata -> fallback")
		apply_default_inputs()
		DirAccess.copy_absolute(path, path + ".bak")
		
		inputs = i_data
		return
	
	inputs = i_data
	InputSerializer.apply_inputmap_from_dict(i_data)


func apply_default_inputs() -> void:
	InputMap.load_from_project_settings()


func validate_input_data(i_data: Dictionary) -> bool:
	for action: StringName in i_data.keys():
		if typeof(i_data[action]) != TYPE_ARRAY:
			return false
		
		var list: Array = i_data[action]
		if typeof(list) != TYPE_ARRAY:
			continue
		
		for ev: Dictionary in i_data[action]:
			if typeof(ev) != TYPE_DICTIONARY:
				return false
			
			if not ev.has("type"):
				return false
	
	return true


#-------------------
#JSON CORE
#-------------------

func save_json(path: String, j_data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Save failed: " + path)
		return
	
	file.store_string(JSON.stringify(j_data, "\t"))
	file.close()


func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Load failed: " + path)
		return {}
	
	var content: String = file.get_as_text()
	file.close()
	
	var result: Variant = JSON.parse_string(content)
	if result == null or typeof(result) != TYPE_DICTIONARY:
		push_warning("Invalid JSON: " + path)
		DirAccess.copy_absolute(path, path + ".bak")
		return {}
	
	return result


func ensure_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

#-------------
#DIALOG MANAGING
#-------------

func has_dialog_flag(flag: String) -> bool:
	return player.dialog_flags.get(flag, false)

func set_dialog_flag(flag: String) -> void:
	player.dialog_flags[flag] = true
	
	if not options.dialog_flags.has(flag):
		options.textboxCount += 1
	
		options.dialog_flags[flag] = true
	
	save_dialog_flags()

func save_dialog_flags() -> void:
	var path: String = SAVE_DIR + "slot_" + str(active_slot) + ".json"
	var data: Dictionary = load_json(path)
	
	data["dialog_flags"] = player.dialog_flags
	
	save_json(path, data)
	save_options()
