extends Node2D

var motion := Vector2(randf_range(-20, 20), randf_range(-10, 10))


func _process(delta: float) -> void:
  position += motion * delta
