extends Node

var tilemaps: Array[TileMapLayer] = []

const footstep_sounds: Dictionary[String, Array] = {
	"dirt": [
		preload("res://Sounds/dirt_1.wav"),
		preload("res://Sounds/dirt_2.wav"),
		preload("res://Sounds/dirt_3.wav")
	],
	"grass": [
		preload("res://Sounds/grass_1.wav"),
		preload("res://Sounds/grass_2.wav"),
		preload("res://Sounds/grass_3.wav")
	]
}

const sound_effect: Dictionary[String, AudioStream] = {
	"landing" : preload("res://Sounds/human-impact-on-ground.mp3"),
	"enter_water": preload("res://Sounds/jump-into-water-splash-sound.mp3"),
	"swing" : preload("res://Sounds/swing-whoosh-110410.mp3"),
	"spin" : preload("res://Sounds/spin.mp3")
}


func play_footstep(position: Vector2) -> void:
	var tile_data: Array = []
	for tilemap: TileMapLayer in tilemaps:
		var tile_position: Vector2 = tilemap.local_to_map(position)
		var data: TileData = tilemap.get_cell_tile_data(tile_position)
		if data:
			tile_data.push_back(data)
	
	if tile_data.size() > 0:
		var tile: TileData = tile_data.back()
		var tile_type: String = tile.get_custom_data("footstep_sound")
		
		if footstep_sounds.has(tile_type):
			var sound: AudioStream = footstep_sounds[tile_type].pick_random()
			var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			audio_player.stream = sound
			get_tree().root.add_child(audio_player)
			audio_player.global_position = position
			audio_player.volume_db = 1
			audio_player.play()
			await  audio_player.finished
			audio_player.queue_free()
			print("sound played")


func player_audio_start(position: Vector2, sound: AudioStream, volume: float) -> void:
	var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.stream = sound
	get_tree().root.add_child(audio_player)
	audio_player.global_position = position
	audio_player.volume_db = volume
	audio_player.play()
	await  audio_player.finished
	audio_player.queue_free()

func audio_player_start_on_node(node: Node2D, sound: AudioStream, volume: float) -> void:
	var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.stream = sound
	node.add_child(audio_player)
	audio_player.global_position = node.global_position
	audio_player.volume_db = volume
	audio_player.max_distance = 400
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()
	
func audio_player_start(position: Vector2, sound: AudioStream, volume: float) -> void:
	var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.stream = sound
	get_tree().root.add_child(audio_player)
	audio_player.global_position = position
	audio_player.volume_db = volume
	audio_player.max_distance = 700
	audio_player.play()
	await  audio_player.finished
	audio_player.queue_free()
