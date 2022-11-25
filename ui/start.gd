extends Control

@export var focus: Control

func _ready() -> void:
  focus.grab_focus()


func _on_cfg_close() -> void:
  focus.grab_focus()
