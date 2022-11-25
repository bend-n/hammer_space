extends ColorRect

signal close

@export var focus: Control

func open() -> void:
  show()
  focus.button.grab_focus()

func _input(event: InputEvent) -> void:
  if visible and event is InputEventKey and event.keycode == KEY_ESCAPE:
    close.emit()
    hide()

func _on_exit_pressed() -> void:
  close.emit()
  hide()
