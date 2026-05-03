extends Node
class_name SoundManager

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var lava_player: AudioStreamPlayer = AudioStreamPlayer.new()

var instance: SoundManagerInstance = null
var listeners: Array[Node2D] = []


func play_sound(sound_name: String, node: Node2D) -> void:
	if instance == null:
		push_warning("Keine Sound Manager Instance Gefunden")
		return
	
	instance.play_sound(sound_name, node)




#func play_attached(sound_name: String, parent: Node2D) -> AudioStreamPlayer2D:
#	if not sounds.has(sound_name):
#		push_warning("Sound nicht gefunden: " + sound_name)
#		return
#		
#	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
#	player.pitch_scale = randf_range(0.9, 1.1)
#	player.bus = "SFX"
#	parent.add_child(player)
#	player.position = Vector2.ZERO
#	player.play()
	
#	return player


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


#func play_sound_effect(effect: String) -> void:
#	var sound: AudioStreamPlayer = AudioStreamPlayer.new()
#	sound.volume_db = G.save_stat_inf.sfxVolume
#	var soundEffects: String = sounds[effect]
#	sound.stream = load(soundEffects)
#	add_child(sound)
#	sound.play()
#	await sound.finished
#	sound.queue_free()
