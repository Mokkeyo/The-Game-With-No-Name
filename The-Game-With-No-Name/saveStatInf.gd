extends Resource
class_name SaveStatInf

@export var version: int = 1

@export var deaths: Array = [0, 0, 0, 0]
@export var vsync: bool = false
@export var musicVolume: float = 1
@export var sfxVolume: float = 0.1
@export var maxVolume: float = 0.5
@export var printFps: bool = false
@export var resolutionIndex: int = 0
@export var resolution: Vector2i = Vector2i(1024,576)
@export var maxFps: int = 0
@export var fullscreen: bool = false
@export var darknessValue: int = 200
@export var darknessOn: bool = true
@export var textboxCount: int = 0
@export var textboxCollected: Array = []
@export var achievments: Array = []
@export var playerName: Array = ["", "", "", ""]

func to_dict() -> Dictionary:
	return {
		"version": version,
		"deaths": deaths,
		"vsync": vsync,
		"musicVolume": musicVolume,
		"sfxVolume": sfxVolume,
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
		"textboxCollected": textboxCollected,
		"achievments": achievments,
		"playerName": playerName
	}

func from_dict(data: Dictionary) -> void:
	deaths = data.get("deaths", [0,0,0,0])
	vsync = data.get("vsync", false)
	musicVolume = data.get("musicVolume", 1.0)
	sfxVolume = data.get("sfxVolume", 0.1)
	maxVolume = data.get("maxVolume", 0.5)
	printFps = data.get("printFps", false)
	
	var res: Dictionary = data.get("resolution", {"x":1024,"y":576})
	if res is Dictionary[String, int]:
		var new_res: Dictionary[String, int] = res as Dictionary[String, int]
		resolution = Vector2i(new_res["x"], new_res["y"])
	
	maxFps = data.get("maxFps", 0)
	fullscreen = data.get("fullscreen", false)
	darknessValue = data.get("darknessValue", 200)
	darknessOn = data.get("darknessOn", true)
	textboxCount = data.get("textboxCount", 0)
	textboxCollected = data.get("textboxCollected", [])
	achievments = data.get("achievments", [])
	playerName = data.get("playerName", ["", "", "", ""])
