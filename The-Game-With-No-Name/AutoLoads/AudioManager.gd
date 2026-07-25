extends Node

const MAX_SFX_PLAYERS: int = 16
const MAX_MUSIC_PLAYERS: int = 2
const MAX_SPATIAL_PLAYERS: int = 32

const SILENT_DB: float = -80.0
#const VOLUME_DB: float = 0.0

const MUSIC_BUS: String = "Music"

var music_tween: Tween
var fade_time: float = 1.0
var current_music_player: int = 0

var music_players: Array[AudioStreamPlayer] = []
var sfx_players: Array[AudioStreamPlayer] = []
var spatial_players: Array[AudioStreamPlayer2D] = []

var _last_variant: Dictionary = {}

func _ready() -> void:
	_create_music_player()
	_create_sfx_players()
	_create_spatial_players()

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
	for i: int in MAX_SPATIAL_PLAYERS:
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(player)
		spatial_players.append(player)
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
	
	for player: AudioStreamPlayer2D in spatial_players:
		if player.playing:
			continue
		
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
