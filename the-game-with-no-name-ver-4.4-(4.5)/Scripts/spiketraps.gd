extends Node2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var spikePlayer: AnimationPlayer = $Spike_Player
@onready var timer: Timer = $Wait_Timer

func _ready() -> void:
	animationPlayer.play("default")

func _on_Wait_Timer_timeout() -> void:
	animationPlayer.play("default")


func _on_AnimationPlayer_animation_finished(_a: String) -> void:
	spikePlayer.play("Trap")


func _on_Spike_Player_animation_finished(_a: String) -> void:
	timer.start()
