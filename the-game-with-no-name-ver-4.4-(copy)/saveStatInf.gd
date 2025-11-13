extends Resource
class_name saveStatInf

@export var deaths: Array[int] = [0, 0, 0, 0]
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
@export var textboxCollected: Array[String] = []
@export var achievments: Array[String] = []
@export var playerName: Array[String] = ["", "", "", ""]
