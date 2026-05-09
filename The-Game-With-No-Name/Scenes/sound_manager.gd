extends Node
class_name SoundManagerInstance

var sfx_pool: Array[AudioStreamPlayer2D] = []
const POOL_SIZE:int = 50

const MAX_HEARING_DISTANCE: int = 150

var last_frame_played : Dictionary = {}

var played_this_frame: Dictionary = {}
var pool_index: int = 0
var last_played: Dictionary[String, float] = {}
const COOLDOWN: float = 0.005


const sounds: Dictionary = {
"Coin": preload("res://Sounds/mixkit-game-treasure-coin-2038.wav"),
"shoot": preload("res://Sounds/mixkit-game-whip-shot-1512.wav"),
"jump": preload("res://Sounds/mixkit-player-jumping-in-a-video-game-2043.wav"),
"magic": preload("res://Sounds/mixkit-wind-magic-whoosh-2610.wav"),
"sword": preload("res://Sounds/mixkit-sword-blade-attack-in-medieval-battle-2762.wav"),
"explosion": preload("res://Sounds/mixkit-sea-mine-explosion-1184.wav"),
"water": preload("res://Sounds/mixkit-deep-water-bubbles-1321.wav"),
"swing": preload("res://Sounds/swing-whoosh-110410.mp3")
}

func _process(_delta: float) -> void:
	played_this_frame.clear()

func _ready() -> void:
	SoundMusic.instance = self
	
	for i: int in POOL_SIZE:
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.bus = "SFX"
		player.max_distance = MAX_HEARING_DISTANCE
		player.attenuation = 2
#		player.finished.connect(_on_player_finished.bind(player))
		add_child(player)
		sfx_pool.append(player)


func play_sound(sound_name: String, node: Node2D) -> void:
	if not sounds.has(sound_name):
		push_warning("Sound nicht gefunden: " + sound_name)
		return
	
#	if not _can_play(sound_name):
#		push_warning(sound_name + " kann nicht gespielt werden")
#		return
	
	var listener: Node2D = _get_closest_listener(node.global_position)
	if listener == null:
		push_warning("Kein Listener Gefunden")
		return
	
	var distance: float = listener.global_position.distance_to(node.global_position)
	
	if distance > MAX_HEARING_DISTANCE:
#		push_warning(sound_name + " ist zu weit weg zum Spielen")
		return
	
	if played_this_frame.has(sound_name):
		push_warning(sound_name + " wurde schon gespielt")
		return
		
	played_this_frame[sound_name] = true
	var player: AudioStreamPlayer2D = _get_player()
	player.pitch_scale = randf_range(0.8, 0.9)
	player.stream = sounds[sound_name]
	player.global_position = node.global_position
#	print(player.global_position)
	player.play()
#	print(sound_name + " wurde gespielt")


func _get_closest_listener(position: Vector2) -> Node2D:
	var closest: Node2D = null
	var closest_dist: float = INF
	
	if SoundMusic.listeners == null:
		push_warning("No Listener found")
	
	for l: Node2D in SoundMusic.listeners:
		var d: float = l.global_position.distance_to(position)
		if d < closest_dist:
			closest_dist = d
			closest = l
	
	return closest


func _can_play(sound_name: String) -> bool:
	var frame: int = Engine.get_process_frames()
	var last_frame: int = last_frame_played.get(sound_name, -1)
	
	if frame == last_frame:
		return false
	
	last_frame_played[sound_name] = frame
	return true


func _get_player() -> AudioStreamPlayer2D:
	for player: AudioStreamPlayer2D in sfx_pool:
		if not player.playing:
			return player
	var player: AudioStreamPlayer2D = sfx_pool[pool_index]
	pool_index = (pool_index + 1) % POOL_SIZE
	player.stop()
	return player
