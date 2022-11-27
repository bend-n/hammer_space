extends Control
class_name Popuppable

const RemapButton := preload("res://addons/remap/RemapButton.gd")

signal close

@export var focus: Control

func open() -> void:
  show()
  if focus is RemapButton:
    focus.button.grab_focus()
  else:
    focus.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
  if visible and event.is_action("ui_cancel"):
    accept_event()
    exit()

func exit() -> void:
  close.emit()
  hide()
