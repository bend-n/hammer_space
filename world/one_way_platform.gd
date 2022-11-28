extends StaticBody2D
class_name OneWayPlatform

@onready @export var shape: CollisionShape2D

func _input(event: InputEvent) -> void:
	if event.is_action("down") and shape.disabled == not event.is_pressed():
		shape.set_deferred("disabled", event.is_pressed())
