class_name InputSerializer

static func event_to_dict(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		return {
			"type": "key",
			"keycode": key_event.keycode
		}
	
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		return {
			"type": "mouse",
			"button": mouse_event.button_index
		}
	
	elif event is InputEventJoypadButton:
		var button_event: InputEventJoypadButton = event as InputEventJoypadButton
		return {
			"type": "joy_button",
			"button": button_event.button_index,
			"device": button_event.device
		}
	
	elif event is InputEventJoypadMotion:
		var motion_event: InputEventJoypadMotion = event as InputEventJoypadMotion
		return {
			"type": "joy_motion",
			"axis": motion_event.axis,
			"axis_sign":  sign(motion_event.axis_value),
			"device": motion_event.device
		}
	
	return  {}


static func dict_to_event(data: Dictionary) -> InputEvent:
	match data.get("type", ""):
		"key":
			var ev:InputEventKey = InputEventKey.new()
			ev.physical_keycode = data.get("keycode", 0)
			return ev
		
		"mouse":
			var ev: InputEventMouseButton = InputEventMouseButton.new()
			ev.button_index = data.get("button", 1)
			return ev
		
		"joy_button":
			var ev: InputEventJoypadButton = InputEventJoypadButton.new()
			ev.button_index = data.get("button", 0)
			ev.device = data.get("device", 0)
			return ev
	
		"joy_motion":
			var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
			ev.axis = data.get("axis", 0)
			ev.axis_value = data.get("axis_sign", 1.0)
			ev.device = data.get("device", 0)
			return ev
	
	return null


static func inputmap_to_dict(actions: Array) -> Dictionary:
	var result: Dictionary = {}
	
	for action: StringName in actions:
		
		if not action.begins_with("player"):
			continue
		
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		var list: Array[Dictionary] = []
		
		for ev: InputEvent in events:
			var d: Dictionary = event_to_dict(ev)
			if not d.is_empty():
				list.append(d)
		
		result[action] = list
	
	return result


static func apply_inputmap_from_dict(data: Dictionary) -> void:
	for action: StringName in data.keys():
		
		if not action.begins_with("player"):
			continue
		
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		
		InputMap.action_erase_events(action)
		
		for ev_data: Dictionary in data[action]:
			if typeof(ev_data) != TYPE_DICTIONARY:
				continue
			
			var ev: InputEvent = dict_to_event(ev_data)
			if ev:
				InputMap.action_add_event(action, ev)


static func set_inputs(data: Dictionary, action: String, event: InputEvent) -> void:
	print(event)
	if not data.has(action):
		push_warning("data doesnt have action: " + action)
		data[action] = [null, null]
	
	var arr: Array = data[action]
	
	if arr.size() < 2:
		arr.resize(2)
	
	var serialized: Dictionary = event_to_dict(event)
	if event is InputEventKey or event is InputEventMouseButton:
		print(serialized)
		data[action][0] = serialized
		return
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		data[action][1] = serialized


static func apply_action_from_dict(data: Dictionary, action: String) -> void:
	if not data.has(action):
		push_warning("Action not fund: " + action)
		return
	
	var events: Array = data[action]
	if typeof(events) != TYPE_ARRAY:
		push_warning("Invalid event array for: " + action)
		return
	
	if not InputMap.has_action(action):
		push_warning("couldnt find action -> added it")
		InputMap.add_action(action)
	
	InputMap.action_erase_events(action)
	
	for ev_data: Dictionary in events:
		if typeof(ev_data) != TYPE_DICTIONARY:
			continue
		
		var ev: InputEvent = dict_to_event(ev_data)
		if ev:
			InputMap.action_add_event(action, ev)


static func get_event_from_action(data: Dictionary, action: String, index: int) -> InputEvent:
	if not data.has(action):
		push_warning("Action not found: " + action)
		return null
	
	var arr: Array = data[action]
	if typeof(arr) != TYPE_ARRAY:
		push_warning("Invalid arrar for: " + action)
		return null
	
	if index < 0 or index >= arr.size():
		push_warning("Index out of bounds for: " + action)
		return null
	
	var ev_data: Dictionary = arr[index]
	
	if typeof(ev_data) != TYPE_DICTIONARY:
		return null
	
	return dict_to_event(ev_data)


 
static func change_device_for_player(data: Dictionary, player_index: int, new_device: int) -> void:
	var prefix: String = "player%d_" % (player_index + 1)
	
	for action: StringName in data.keys():
		if not action.begins_with(prefix):
			continue
		
		var events: Array = data[action]
		if typeof(events) != TYPE_ARRAY:
			continue
		
		for ev: Dictionary in events:
			if typeof(ev) != TYPE_DICTIONARY:
				continue
			
			var type: String = ev.get("type", "")
			
			if type == "joy_button" or type == "joy_motion":
				ev["device"] = new_device
				print("assinged controller")
