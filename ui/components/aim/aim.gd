extends Node
class_name AimGizmo

signal cancel()
signal throw(rot: float)

var current_rotation: float

# hold down this long to cancel
const cancel_time := 0.15

var cancel_left_time := cancel_time

@export var arrow: Line2D
@export var enabled := true:
  set(p_e):
    enabled = p_e
    set_process(enabled)

func _ready() -> void:
  enabled = enabled # trigger the setter

func _process(delta: float) -> void:
  var v := Vector2(Input.get_axis(&"left", &"right"), Input.get_axis(&"up", &"down"))
  if Input.is_action_pressed("ui_cancel"):
    cancel_left_time = cancel_time
    cancel.emit()
    return
  if v.is_zero_approx():
    v.x = Globals.player.sprite.scale.x # default to current facing direction
  elif Util.is_in_range(v.y, 0.9, 1) and Util.is_in_range(v.x, -0.1, 0.1) and Globals.player.is_on_floor():
    cancel_left_time -= delta
    if cancel_left_time < 0:
      cancel_left_time = cancel_time
      cancel.emit()
      return
  var angle := v.angle()
  current_rotation = angle
  arrow.rotation = angle
  if Input.is_action_just_released(&"throw"):
    throw.emit(angle)
