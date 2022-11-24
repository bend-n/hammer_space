extends Node
class_name Util


static func instance_scene(scene: PackedScene, position: Vector2, on: Node) -> Node:
  var instance := scene.instantiate() as Node2D
  on.add_child(instance)
  instance.global_position = position
  return instance


func instance_scene_on_main(scene: PackedScene, position: Vector2) -> Node:
  return Util.instance_scene(scene, position, get_tree().current_scene)

func instance_scene_on_level(scene: PackedScene, position: Vector2) -> Node:
  return Util.instance_scene(scene, position, Globals.levelmanager.current_level)

static func str_vec(vec: Vector2) -> String:
  var map := {Vector2.UP: "up", Vector2.DOWN: "down", Vector2.LEFT: "left", Vector2.RIGHT: "right"}
  return map.get(vec, str(vec))


static func sub(a: Array, b: Array) -> Array:
  return a.filter(func(item) -> bool: return not item in b)


static func out_of_bounds(v: Vector2i, rect: Vector2i) -> bool:
  return v.x > rect.x or v.y > rect.y or v.x < 0 or v.y < 0


const hammer_path_fmt := "res://hammers/hammer_%s.tscn"
const hammers: Array[PackedScene] = [
  preload(hammer_path_fmt % "01"),
  preload(hammer_path_fmt % "02"),
  preload(hammer_path_fmt % "03"),
]

func get_hammer() -> PackedScene:
  return hammers[randi() % len(hammers)]
