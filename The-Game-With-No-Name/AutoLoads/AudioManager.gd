extends Node

const MAX_SFX_PLAYERS: int = 16
const MAX_MUSIC_PLAYERS: int = 2
const MAX_SPATIAL_PLAYERS: int = 32

const AMBIENT_SWITCH_HYSTERESIS: float = 50.0
const SILENT_DB: float = -80.0

const MUSIC_BUS: String = "Music"

var world: Node
var ambient_timer: float = 0.0

var music_tween: Tween
var fade_time: float = 1.0
var current_music_player: int = 0

var ambient_sources: Dictionary[StringName, Array] = {}
var active_sources: Dictionary[StringName, AudioSource2D] = {}
var playback_positions: Dictionary [StringName, float] = {}
var _last_played_frame: Dictionary = {}

var music_players: Array[AudioStreamPlayer] = []

var sfx_players: Array[AudioStreamPlayer] = []

var spatial_players: Array[AudioStreamPlayer2D] = []

var _last_variant: Dictionary = {}

func _ready() -> void:
	await get_tree().process_frame
	_create_music_player()
	_create_sfx_players()
#	_create_spatial_players()

#region player creators
func _create_music_player() -> void:
	for i: int in MAX_MUSIC_PLAYERS:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = MUSIC_BUS
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		music_players.append(player)

func _create_sfx_players() -> void:
	for i: int in MAX_SFX_PLAYERS:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)


func _create_spatial_players() -> void:
	if !world:
		return
	for i: int in MAX_SPATIAL_PLAYERS:
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		world.add_child(player)
		spatial_players.append(player)
	print("spatial world", spatial_players[0].get_world_2d())
#endregion

#region music functions
func play_music(sound: SoundEffect) -> void:
	var stream: AudioStream = _get_stream(sound)
	
	if stream == null:
		return
	
	var current_player: AudioStreamPlayer = music_players[current_music_player]
	
	if !current_player.playing:
		current_player.stream = stream
		current_player.volume_db = sound.volume_db
		current_player.play()
		return
	
	if current_player.stream == stream and current_player.playing:
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
		SILENT_DB,
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


func stop_music() -> void:
	var player: AudioStreamPlayer= music_players[current_music_player]

	if !player.playing:
		return

	if music_tween:
		music_tween.kill()
	
	var tween: Tween = create_tween()
	music_tween = tween
	
	tween.tween_property(player, "volume_db", SILENT_DB, fade_time)

	await tween.finished
	
	if music_tween != tween:
		return
	
	music_tween = null
	
	player.stop()


func _get_inactive_music_player() -> int:
	return (current_music_player + 1) % MAX_MUSIC_PLAYERS
#endregion

#region sfx functions
func play_sfx_at(sound: SoundEffect, position: Vector2) -> void:
	var stream: AudioStream = _get_stream(sound)
	
	if stream == null:
		return
	
	if !_can_play(sound, stream, spatial_players):
		return
	
	
	for player: AudioStreamPlayer2D in spatial_players:
		if player.playing:
			continue
		
		player.max_distance = sound.max_distance
			
		player.global_position = position
		player.stream = stream
		player.bus = sound.bus
		player.volume_db = sound.volume_db
		
		if sound.random_pitch:
			player.pitch_scale = randf_range(
				1.0 - sound.pitch_variation,
				1.0 + sound.pitch_variation
			)
		else:
			player.pitch_scale = 1.0
	
		player.play()
		return


func play_sfx(sound: SoundEffect) -> void:
	if sound == null:
		return
	
	var stream: AudioStream = _get_stream(sound)
	
	if stream == null:
		return
	
	if !_can_play(sound, stream, sfx_players):
		return
	
	for player: AudioStreamPlayer in sfx_players:
		if player.playing:
			continue
		
		player.stream = stream
		player.bus = sound.bus
		player.volume_db = sound.volume_db
		
		if sound.random_pitch:
			player.pitch_scale = randf_range(
				1.0 - sound.pitch_variation,
				1.0 + sound.pitch_variation
			)
		else:
			player.pitch_scale = 1.0
	
		player.play()
		return


func _get_stream(sound: SoundEffect) -> AudioStream:
	var count: int = sound.streams.size()
	
	if count == 0:
		return
	
	if count == 1:
		return sound.streams[0]
	
	var last: int = _last_variant.get(sound, -1)
	var index: int = randi_range(0, count -1)
	
	while count > 1 and index == last:
		index = randi_range(0, count -1)
	
	_last_variant[sound] = index
	
	return sound.streams[index]
#endregion

#region ambient functions

func _process(delta: float) -> void:
	ambient_timer += delta
	
	if ambient_timer >= 0.2:
		ambient_timer = 0.0
		_update_ambient()


func _update_ambient() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("Player")
	
	if player == null:
		return
	
	for group: StringName in ambient_sources.keys():
		var sources: Array = ambient_sources[group]
		
		var closest: AudioSource2D
		var closest_distance: float = INF
		
		for source: AudioSource2D in sources:
			var distance: float = source.global_position.distance_to(
				player.global_position
			)
			
			if distance > source.activation_distance:
				continue
			
			if distance < closest_distance:
				closest = source
				closest_distance = distance
		
		var current: AudioSource2D = active_sources.get(group)

		# Hysterese
		if current != null and closest != null and current != closest:
			var current_distance: float = current.global_position.distance_to(
				player.global_position
			)

			# Nur wechseln, wenn die neue Quelle deutlich näher ist
			if closest_distance + AMBIENT_SWITCH_HYSTERESIS >= current_distance:
				closest = current

		# Keine Änderung
		if current == closest:
			continue

		# Keine Quelle mehr -> ausfaden
		if closest == null:
			if current:
				playback_positions[group] = current.playback_position()
				current.fade_out()

			active_sources.erase(group)
			continue

		# Erste Quelle der Gruppe
		if current == null:
			var pos: float= playback_positions.get(group, 0.0)
			closest.fade_in(pos)
			active_sources[group] = closest
			continue

		# Wechsel auf andere Quelle
		playback_positions[group] = current.playback_position()

		current.stop()

		closest.play(playback_positions[group])

		active_sources[group] = closest

func register_source(source: AudioSource2D) -> void:
	var group: StringName = source.sound.ambient_group
	if !ambient_sources.has(group):
		ambient_sources[group] = []
	
	var sources: Array = ambient_sources[group]
	
	if sources.has(source):
		return
	
	sources.append(source)


func unregister_source(source: AudioSource2D) -> void:
	if source == null:
		return
	
	var group: StringName = source.sound.ambient_group
	
	if ambient_sources.has(group):
		var sources: Array = ambient_sources[group]
		sources.erase(source)
		
		if sources.is_empty():
			ambient_sources.erase(group)
	
	if active_sources.get(group) == source:
		active_sources.erase(group)

#endregion

#region help functions
func setup_player(player: AudioStreamPlayer2D, sound: SoundEffect) -> void:
	if sound == null:
		return
	
	var stream: AudioStream = _get_stream(sound)
	
	if stream == null:
		return
	
	player.stream = stream
	player.bus = sound.bus
	player.volume_db = sound.volume_db
		
	if sound.random_pitch:
		player.pitch_scale = randf_range(
			1.0 - sound.pitch_variation,
			1.0 + sound.pitch_variation
		)
	else:
		player.pitch_scale = 1.0


func _can_play(sound: SoundEffect, stream: AudioStream, players: Array) -> bool:
	var frame:int = Engine.get_process_frames()

	if sound.min_frame_interval > 0:
		var last: int = _last_played_frame.get(sound, -999999)

		if frame - last < sound.min_frame_interval:
			return false

	var instances: int= 0

	for player: AudioStreamPlayer2D in players:
		if player.playing and player.stream == stream:
			instances += 1

	if instances >= sound.max_instances:
		return false

	_last_played_frame[sound] = frame
	return true
#endregion

func set_world(new_world: Node) -> void:
	world = new_world

	for player: AudioStreamPlayer2D in spatial_players:
		if is_instance_valid(player):
			player.queue_free()

	spatial_players.clear()
	_create_spatial_players()
