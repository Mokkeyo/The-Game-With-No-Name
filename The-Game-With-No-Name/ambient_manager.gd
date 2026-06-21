extends Node
class_name AmbientManager

static var instance: AmbientManager

@export var max_same_sound: int  = 2

static var sounds: Dictionary[String, AudioStream] = {
	"spin": preload("res://Sounds/spin.mp3"),
	"lava": preload("res://Sounds/lava-loop-3-28887(1).mp3"),
	"water": preload("res://Sounds/water-in-cave-hq-343057.mp3")
}

var ambient_nodes: Array[AmbientSound] = []
var invalid_nodes: Array[AmbientSound] = []
var update_timer: float = 0.0

func _ready() -> void:
	instance = self


func register(node: AmbientSound) -> void:
	if ambient_nodes.has(node):
		return
	
	ambient_nodes.append(node)

func unregister(node: AmbientSound) -> void:
	ambient_nodes.erase(node)

func _process(delta: float) -> void:
	
	update_timer -= delta
	
	if update_timer > 0:
		return
	
	update_timer = 0.2
	
	if SoundMusic.listeners.is_empty():
		return
	
	var grouped: Dictionary[String, Array] = {}
	
	for sound: AmbientSound in ambient_nodes:
		if not is_instance_valid(sound):
			push_warning("instance invalid")
			invalid_nodes.append(sound)
			continue
		
		var listener: Node2D = get_closest_listener(sound.global_position)
		
		if listener == null:
			continue
		
		var distance: float = listener.global_position.distance_to(sound.global_position)
		
		if not grouped.has(sound.sound_id):
			grouped[sound.sound_id] = []
		
		grouped[sound.sound_id].append({"node": sound, "distance": distance})
		
	
	for sound: AmbientSound in invalid_nodes:
		ambient_nodes.erase(sound)
	
	invalid_nodes.clear()
	
	
	var processed: Dictionary = {}
	
	for sound_id: String in grouped.keys():
		var arr: Array = grouped[sound_id]
		
		arr.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a["distance"] < b["distance"])
		
		for i: int in arr.size():
			var sound: AmbientSound = arr[i]["node"]
			var distance: float = arr[i]["distance"]
			
			processed[sound] = true
			
			if i < max_same_sound:
				if sound.active_sound:
					if distance > sound.deactivation_distance:
						sound.set_active(false)
				
				else:
					if distance < sound.activation_distance:
						sound.set_active(true)
			else:
				sound.set_active(false)
	
	
	for sound: AmbientSound in ambient_nodes:
		if not is_instance_valid(sound):
			continue
		
		if sound.active_sound and not processed.has(sound):
			sound.set_active(false)
	
func get_closest_listener(position: Vector2) -> Node2D:
	var closest: Node2D
	var closest_distance: float = INF
	
	
	for listener: Node2D in SoundMusic.listeners:
		var d: float= listener.global_position.distance_to(position)
		
		if d < closest_distance:
			closest_distance = d
			closest = listener
	
	
	return closest
