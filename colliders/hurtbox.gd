extends Area2D
class_name Hurtbox

func _ready() -> void:
    assert(owner is Hittable)