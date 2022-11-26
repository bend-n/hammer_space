extends Control

@onready var full := $Full as TextureRect


func _ready():
  Globals.player.hp_changed.connect(_hp_changed)


func _hp_changed(hp: int):
  full.size.x = hp * 5 + 1
