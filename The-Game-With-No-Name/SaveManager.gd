extends Node
class_name SaveManager

const SAVE_DIR: String = "res://Save_Files"

var active_slot: int = 0

var player: SaveStat = SaveStat.new()
var options: SaveStatInf = SaveStatInf.new()

func _ready() -> void:
	ensure_dir()

#-------------------
#SAVE
#-------------------

func save_all() -> void:
	save_data()
	save_options()
	save_inputs()

func save_data() -> void:
	var path: String = SAVE_DIR + "slot_" + str(active_slot) + ".json"
	save_json(path, player.to_dict())

func save_options() -> void:
	var path: String = SAVE_DIR + "options.json"
	save_json(path, options.to_dict())

func save_inputs() -> void:
	var path: String = SAVE_DIR  +  "inputs.json"
	var i_data: Dictionary = InputSerializer.inputmap_to_dict(InputMap.get_actions())
	save_json(path, i_data)

#-------------------
#LOAD
#-------------------

func load_all() -> void:
	load_data()
	load_options()
	load_inputs()

func load_data() -> void:
	var path: String = SAVE_DIR + "slot_" + str(active_slot) + ".json"
	var a_data: Dictionary = load_json(path)
	
	if a_data.is_empty():
		push_warning("Save file is missing or invalid -> slot_" + str(active_slot))
		save_data()
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
		save_inputs()
		return
	
	if not validate_input_data(i_data):
		push_warning("Invalid inputdata -> fallback")
		apply_default_inputs()
		DirAccess.copy_absolute(path, path + ".bak")
		return
	
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
	print("SAVING FILE: ", path)
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
