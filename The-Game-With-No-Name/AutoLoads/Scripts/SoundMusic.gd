extends Node

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var music_tracks: Dictionary = {
"Underground": "res://Sounds/06 - Underground.mp3",
"Boss": "res://Sounds/Dark Souls III Soundtrack OST - Vordt of the Boreal Valley.mp3",
"Wind": "res://Sounds/WhistlingWindStead PE033401.wav",
"Battle": "res://Sounds/Epic-battle-music-grzegorz-majcherczyk-heroica.mp3"
}

var sound_effects: Dictionary = {
"Coin": "res://Sounds/mixkit-game-treasure-coin-2038.wav",
"shoot": "res://Sounds/mixkit-game-whip-shot-1512.wav",
"jump": "res://Sounds/mixkit-player-jumping-in-a-video-game-2043.wav",
"magic": "res://Sounds/mixkit-wind-magic-whoosh-2610.wav",
"sword": "res://Sounds/mixkit-sword-blade-attack-in-medieval-battle-2762.wav",
"explosion": "res://Sounds/mixkit-sea-mine-explosion-1184.wav",
"water": "res://Sounds/mixkit-deep-water-bubbles-1321.wav"
}

func chance_musice_volume(value: float) -> void:
	G.SaveStatInf.musicVolume = linear_to_db(value * G.SaveStatInf.maxVolume)
	music_player.volume_db = G.SaveStatInf.musicVolume

func chance_max_volume(value: float) -> void:
	G.SaveStatInf.maxVolume = value
	chance_musice_volume(G.SaveStatInf.musicVolume)
	chance_sound_volume(G.SaveStatInf.sfxVolume)

func chance_sound_volume(value: float) -> void:
	G.SaveStatInf.sfxVolume = linear_to_db(value * G.SaveStatInf.maxVolume)

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
#	max_db = G.SaveStatInf.maxVolume
#	music_db = G.SaveStatInf.musicVolume
#	sound_db = G.SaveStatInf.sfxVolume
#	if G.boss == null:
#		music_player.stream = load(music_tracks["Underground"])
#		add_child(music_player)
#		music_player.play()

func play_boss() -> void:
#	music_player.stream = load(music_tracks["Boss"])
#	add_child(music_player)
	music_player.play()

func play_wind() -> void:
#	music_player.stream = load(music_tracks["Wind"])
#	add_child(music_player)
	music_player.play()
	
func play_underground() -> void:
#	music_player.stream = load(music_tracks["Underground"])
#	add_child(music_player)
	music_player.play()
	
func play_battle() -> void:
	music_player.play()
	
func play_sound_effect(effect: String) -> void:
	var sound: AudioStreamPlayer = AudioStreamPlayer.new()
	sound.volume_db = G.SaveStatInf.sfxVolume
	var soundEffects: String = sound_effects[effect]
	sound.stream = load(soundEffects)
	add_child(sound)
	sound.play()
	await sound.finished
	sound.queue_free()
