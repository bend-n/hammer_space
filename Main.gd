extends Node2D

func _ready() -> void:
	MusicPlayer.p()

func _exit_tree() -> void:
	MusicPlayer.s()
