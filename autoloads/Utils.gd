extends Node
class_name Util


func instance_scene_on_main(scene: PackedScene, position: Vector2) -> Node:
	var main = get_tree().current_scene
	var instance = scene.instantiate()
	main.add_child(instance)
	instance.global_position = position
	return instance


static func str_vec(vec: Vector2) -> String:
	var map := {Vector2.UP: "up", Vector2.DOWN: "down", Vector2.LEFT: "left", Vector2.RIGHT: "right"}
	return map.get(vec, str(vec))


static func sub(a: Array, b: Array) -> Array:
	return a.filter(func(item) -> bool: return not item in b)
