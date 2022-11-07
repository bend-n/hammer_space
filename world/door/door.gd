extends Area2D
class_name Door

var dir: Vector2i


func _on_body_entered(_p: Player) -> void:
	Events.emit_signal(&"change_level", dir)
