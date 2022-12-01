extends Node2D

@export var playback_speed := 1.0

func _ready() -> void:
	$player.playback_speed = playback_speed

