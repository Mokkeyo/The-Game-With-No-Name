extends AudioStreamPlayer2D
class_name AmbientSound

@export var sound_id: String

@export var activation_distance: float = 200.0
@export var deactivation_distance: float = 230.0

var fade_tween: Tween
var active_sound: bool = false

@export var auto_play: bool = true

func _ready() -> void:
	bus = "SFX"
	
	AmbientManager.instance.register(self)
	
	if not AmbientManager.sounds.has(sound_id):
		push_warning(
			"Ambient sound missing: " + sound_id
		)
		return
	
	stream = AmbientManager.sounds.get(sound_id)


func set_active(value: bool) -> void:
	if active_sound == value:
		return
		
	active_sound = value
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	
	if active_sound:
		if not playing:
			volume_db = -80
			play()
		fade_tween.tween_property(self, "volume_db", 0.0, 0.3)
	else:
		fade_tween.tween_property(self, "volume_db", -80.0, 0.3)
		fade_tween.finished.connect(_on_fade_finished, CONNECT_ONE_SHOT)


func _on_fade_finished() -> void:
	if not active_sound:
		stop()


func _exit_tree() -> void:
	if AmbientManager.instance:
		AmbientManager.instance.unregister(self)
