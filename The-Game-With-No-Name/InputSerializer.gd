class_name InputSerializer

static func event_to_dict(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		return {
			"type": "key",
			"keycode": key_event.physical_keycode
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
