extends Resource
class_name SaveStatInf

@export var version: int = 1

@export var deaths: Array[int] = [0, 0, 0, 0]
@export var vsync: bool = false
@export var musicVolume: float = 1
@export var sfxVolume: float = 0.5
@export var ambientVolume: float = 0.5
@export var maxVolume: float = 0.5
@export var printFps: bool = false
@export var resolutionIndex: int = 0
@export var resolution: Vector2i = Vector2i(1024,576)
@export var maxFps: int = 0
@export var fullscreen: bool = false
@export var darknessValue: int = 200
@export var darknessOn: bool = true
@export var textboxCount: int = 0
@export var dialog_flags: Dictionary = {}
@export var achievments: Array[String] = []
@export var playerName: Array[String] = ["", "", "", ""]

func to_dict() -> Dictionary:
	return {
		"version": version,
		"deaths": deaths,
		"vsync": vsync,
		"musicVolume": musicVolume,
		"sfxVolume": sfxVolume,
		"ambientVolume": ambientVolume,
		"maxVolume": maxVolume,
		"printFps": printFps,
		"resolution": {
			"x": resolution.x,
			"y": resolution.y
		},
		"maxFps": maxFps,
		"fullscreen": fullscreen,
		"darknessValue": darknessValue,
		"darknessOn": darknessOn,
		"textboxCount": textboxCount,
		"dialog_flags": dialog_flags,
		"achievments": achievments,
		"playerName": playerName
	}

func from_dict(data: Dictionary) -> void:
	var arr: Array = data.get("deaths", [0,0,0,0])
	deaths.clear()
	for v: Variant in arr:
		if v is float:
			deaths.append(v)
		else:
			push_warning("couldnt convert to int -> deaths")
	
	vsync = data.get("vsync", false)
	musicVolume = data.get("musicVolume", 1.0)
	ambientVolume = data.get("ambientVolume", 0.5)
	sfxVolume = data.get("sfxVolume", 0.5)
	maxVolume = data.get("maxVolume", 0.5)
	printFps = data.get("printFps", false)
	
	var res: Dictionary = data.get("resolution", {})
	var x: int = (res.get("x", 1024))
	var y: int = (res.get("y", 576))
	resolution = Vector2i(x, y)
	
	maxFps = data.get("maxFps", 0)
	fullscreen = data.get("fullscreen", false)
	darknessValue = data.get("darknessValue", 200)
	darknessOn = data.get("darknessOn", true)
	textboxCount = data.get("textboxCount", 0)
	
	arr = data.get("textboxCollected", [])
	dialog_flags = data.get("dialog_flags", {})
	
	achievments.clear()
	arr = data.get("achievments", [])
	for v: Variant in arr:
		if v is String:
			achievments.append(v)
		else:
			push_warning("couldnt convert to string -> achievments")
	
	playerName.clear()
	arr = data.get("playerName", ["", "", "", ""])
	for v: Variant in arr:
		if v is String:
			playerName.append(v)
		else:
			push_warning("couldnt convert to string -> playerName")
