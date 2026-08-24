extends Node

const MAX_UI_SFX_PLAYERS: int = 4
const MAX_MUSIC_PLAYERS: int = 2
const MAX_SFX_PLAYERS: int = 32
const MAX_AMBIENT_PLAYERS: int = 5

const AMBIENT_SWITCH_HYSTERESIS: float = 50.0
const SILENT_DB: float = -80.0

var listener: Node2D = null
var world: Node = null

var ambient_timer: float = 0.0
var ambient_sources: Dictionary[SoundEffect, Array] = {}
var active_sources: Dictionary[SoundEffect, AudioSource2D] = {}
var active_players: Dictionary[SoundEffect, AudioStreamPlayer2D] = {}
var playback_positions: Dictionary[SoundEffect, float] = {}

var _last_variant: Dictionary[SoundEffect, int] = {}

var pending_sfx: Array[SFXRequest] = []

#music players helper var
var current_music_player: int = 0
var music_tween: Tween
var fade_time: float = 0.5

var music_players: Array[AudioStreamPlayer] = []
var ui_sfx_players: Array[AudioStreamPlayer] = []
var sfx_players: Array[AudioStreamPlayer2D] = []
var ambient_players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	setup_audio()

func _process(delta: float) -> void:
	_process_pending_sfx()
	
	ambient_timer += delta
	
	if ambient_timer >= 0.2:
		ambient_timer = 0.0
		_update_ambient()
	
	_update_ambient_players()

#region Audio Creator Functions
func setup_audio() -> void:
	_create_music_player()
	_create_ui_sfx_player()

func _create_music_player() -> void:
	music_players = _create_audio_player(MAX_MUSIC_PLAYERS, "Music")

func _create_ui_sfx_player() -> void:
	ui_sfx_players = _create_audio_player(MAX_UI_SFX_PLAYERS, "UI_SFX")


func _create_audio_player(count: int, bus: String = "") -> Array[AudioStreamPlayer]:
	var players: Array[AudioStreamPlayer] = []
	
	for i: int in count:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		if bus != "":
			player.bus = bus
		
		add_child(player)
		players.append(player)
	
	return players
#endregion

#region Audio 2D Creator Functions

func setup_audio_2d(w: Node) -> void:
	world = w
	listener = get_tree().get_first_node_in_group("Player")
	free_player(sfx_players)
	free_player(ambient_players)
	_create_sfx_player()
	_create_ambient_player()


func free_player(players: Array[AudioStreamPlayer2D]) -> void:
	for player: AudioStreamPlayer2D in players:
		if is_instance_valid(player):
			player.queue_free()
	
	players.clear()


func _create_sfx_player() -> void:
	sfx_players = _create_audio_2d_player(MAX_SFX_PLAYERS, "SFX")

func _create_ambient_player() -> void:
	ambient_players = _create_audio_2d_player(MAX_AMBIENT_PLAYERS, "Ambient")

func _create_audio_2d_player(count: int, bus: String) -> Array[AudioStreamPlayer2D]:
	var players: Array[AudioStreamPlayer2D] = []
	
	for i: int in count:
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		
		player.bus = bus
		
		world.add_child(player)
		players.append(player)
	
	return players
#endregion

#region Music Functions
func play_music(sound: SoundEffect) -> void:
	var stream: AudioStream = _get_stream(sound)
	
	if stream == null:
		push_warning("No Stream found in: ", sound.resource_name)
		return
	
	var current_player: AudioStreamPlayer = music_players[current_music_player]
	
	if !current_player.playing:
		current_player.stream = stream
		current_player.volume_db = sound.volume_db
		current_player.play()
		return
	
	if current_player.stream == stream:
		return
	
	
	var next_index: int = _get_inactive_music_player()
	var next_player: AudioStreamPlayer = music_players[next_index]
	
	next_player.stop()
	next_player.stream = stream
	next_player.volume_db = SILENT_DB
	next_player.play()
	
	if music_tween:
		music_tween.kill()
	
	var tween: Tween = create_tween()
	music_tween = tween
	
	tween.parallel().tween_property(
		current_player,
		"volume_db",
		SILENT_DB,+
		fade_time
	)

	tween.parallel().tween_property(
		next_player,
		"volume_db",
		sound.volume_db,
		fade_time
	)
	
	await tween.finished
	
	if music_tween != tween:
		return
	
	music_tween = null
	
	current_player.stop()
	current_player.volume_db = sound.volume_db
	current_music_player = next_index


func _get_inactive_music_player() -> int:
	return (current_music_player + 1) % MAX_MUSIC_PLAYERS
#endregion

#region UI SFX Functions

func play_ui_sfx(sound: SoundEffect) -> void:
	var stream: AudioStream = _get_stream(sound)
	
	if stream == null:
		push_warning("No Stream found in: ", sound.resource_name)
		return
	
	var player: AudioStreamPlayer = _get_free_audio_player(ui_sfx_players)
	
	if player == null:
		push_warning("No Free Player found")
		return
	
	player.stream = stream
	player.volume_db = sound.volume_db
	if sound.random_pitch:
		player.pitch_scale = randf_range(
			1.0 - sound.pitch_variation,
			1.0 + sound.pitch_variation
		)
	else:
		player.pitch_scale = 1.0
		
	player.play()

func _get_free_audio_player(players: Array[AudioStreamPlayer]) -> AudioStreamPlayer:
	for i: int in players.size():
		if players[i].playing:
			continue
		
		return players[i]
	
	return null

#endregion

#region SFX Functions

func play_sfx(sound: SoundEffect, position: Vector2) -> void:
	var stream: AudioStream = _get_stream(sound)
	
	if stream == null:
		push_warning("No Stream found in: ", sound.resource_name)
		return
	
	pending_sfx.append(
		SFXRequest.new(sound, stream, position)
	)

func _play_request(request: SFXRequest) -> void:
	var player: AudioStreamPlayer2D = _get_free_audio_2d_player(sfx_players)
	
	if player == null:
		push_warning("No free SFX player for: ", request.sound.resource_name)
		return
	
	var sound: SoundEffect = request.sound
	
	player.global_position = request.position
	player.max_distance = sound.max_distance
	
	player.stream = request.stream
	player.volume_db = sound.volume_db
	
	if sound.random_pitch:
		player.pitch_scale = randf_range(
			1.0 - sound.pitch_variation,
			1.0 + sound.pitch_variation
		)
	else:
		player.pitch_scale = 1.0
	
	player.play()


func _get_free_audio_2d_player(players: Array[AudioStreamPlayer2D]) -> AudioStreamPlayer2D:
	for player: AudioStreamPlayer2D in players:
		if player.playing:
			continue
		
		return player
	
	return null


func _process_pending_sfx() -> void:
	if pending_sfx.is_empty():
		return
	
	if listener == null:
		pending_sfx.clear()
		
		return
	
	
	var listener_position: Vector2 = listener.global_position
	
	pending_sfx.sort_custom(
		func(a:SFXRequest, b: SFXRequest) -> bool:
			return a.position.distance_squared_to(listener_position) \
			< b.position.distance_squared_to(listener_position)
	)
	
	var played: Dictionary = {}
	
	for request: SFXRequest in pending_sfx:
		if played.has(request.sound):
			continue
	
		_play_request(request)
		played[request.sound] = true
	
	pending_sfx.clear()
	
#endregion

#region Ambient Functions

func _update_ambient() -> void:
	if listener == null:
		return
	
	for sound: SoundEffect in ambient_sources:
		var closest: AudioSource2D = _get_closest_source(sound)
		var current: AudioSource2D = active_sources.get(sound)
		
		if current != null and closest != null:
			closest = _apply_hysteresis(current, closest)
		
		if current == closest:
			continue
		
		_switch_ambient(sound, current, closest)


func _get_closest_source(sound: SoundEffect) -> AudioSource2D:
	var closest: AudioSource2D
	var closest_distance: float  = INF
	
	for source: AudioSource2D in ambient_sources[sound]:
		var distance: float = source.global_position.distance_to(
			listener.global_position
		)
		
		if distance > source.activation_distance:
			continue
		
		if distance < closest_distance:
			closest = source
			closest_distance = distance
	
	return closest


func _apply_hysteresis(
	current: AudioSource2D,
	closest: AudioSource2D
) -> AudioSource2D:

	var listener_position :Vector2 = listener.global_position

	var current_distance: float = current.global_position.distance_squared_to(
		listener_position
	)

	var closest_distance:float = closest.global_position.distance_squared_to(
		listener_position
	)

	if closest_distance + AMBIENT_SWITCH_HYSTERESIS * AMBIENT_SWITCH_HYSTERESIS >= current_distance:
		return current

	return closest


func _switch_ambient(
	sound: SoundEffect,
	current: AudioSource2D,
	closest: AudioSource2D
) -> void:

	if closest == null:
		_stop_ambient(sound)
		return

	if current == null:
		_start_ambient(sound, closest)
		return

	playback_positions[sound] = \
		active_players[sound].get_playback_position()

	active_sources[sound] = closest

	active_players[sound].play(
		playback_positions[sound]
	)

func _start_ambient(
	sound: SoundEffect,
	source: AudioSource2D
) -> void:

	var player : AudioStreamPlayer2D = _get_free_audio_2d_player(ambient_players)

	if player == null:
		return

	player.global_position = source.global_position
	player.stream = _get_stream(sound)
	player.volume_db = sound.volume_db
	player.max_distance = sound.max_distance
	var pos: float = playback_positions.get(sound, 0.0)
	player.play(pos)

	active_sources[sound] = source
	active_players[sound] = player

func _stop_ambient(sound: SoundEffect) -> void:
	var player: AudioStreamPlayer2D = active_players.get(sound)

	if player == null:
		return

	playback_positions[sound] = player.get_playback_position()

	player.stop()

	active_players.erase(sound)
	active_sources.erase(sound)

func _update_ambient_players() -> void:
	
	for sound: SoundEffect in active_players:
		if !active_sources.has(sound):
			continue
		
		var player :AudioStreamPlayer2D = active_players[sound]
		var source : AudioSource2D = active_sources[sound]

		player.global_position = source.global_position


func register_source(source: AudioSource2D) -> void:
	var group: SoundEffect = source.sound
	
	if !ambient_sources.has(group):
		ambient_sources[group] = []
	
	var sources: Array = ambient_sources[group]
	
	if sources.has(source):
		return
	
	sources.append(source)


func unregister_source(source: AudioSource2D) -> void:
	if source == null:
		return
	
	var group: SoundEffect = source.sound
	
	if ambient_sources.has(group):
		var sources: Array = ambient_sources[group]
		sources.erase(source)
		
		if sources.is_empty():
			ambient_sources.erase(group)
	
	if active_sources.get(group) == source:
		active_sources.erase(group)


func stop_all_ambients() -> void:
	for sound: SoundEffect in active_players.keys():
		_stop_ambient(sound)
	
	playback_positions.clear()
	active_players.clear()
	active_sources.clear()


#endregion

#region Helper Functions
func _get_stream(sound: SoundEffect) -> AudioStream:
	var count: int  = sound.streams.size()
	
	if count == 0:
		push_warning("no sounds found in: ", sound.resource_name)
		return
	
	if count == 1:
		return sound.streams[0]
	
	var last: int = _last_variant.get(sound, -1)
	var index: int = randi_range(0, count -1)
	
	while index == last:
		index = randi_range(0, count -1)
	
	_last_variant[sound] = index
	
	return sound.streams[index]
#endregion
