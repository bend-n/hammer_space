extends Node

var player: Player = null
var levelmanager: LevelManager = null

func _init() -> void:
    RenderingServer.set_default_clear_color(Color.BLACK)
