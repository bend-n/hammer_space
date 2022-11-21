extends Node2D
class_name BlockDoor

const DustEffect := preload("res://fx/wall_dust.tscn")

@onready @export var path_follower: PathFollow2D

func dust(mod: int) -> void:
  var i: Node2D = (
    Utils . instance_scene_on_main(DustEffect, global_position + Vector2(randi_range(3, 5), (16 + 7) * mod))
  )
  i.rotation = (PI / 2) * mod

## Opens this door
func open() -> void:
  dust(1)
  dust(-1)
  var t := create_tween().set_ease(Tween.EASE_IN)
  t.tween_property(path_follower, "progress_ratio", 1, 2)
  await t.finished
  queue_free()
