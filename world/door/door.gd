extends Area2D
class_name Door

## The direction the player should go in when going through this door
var dir: Vector2i

func _on_body_entered(_p: Player) -> void:
  Events.change_level.emit(dir)
