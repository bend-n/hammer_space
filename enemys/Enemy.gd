## A enemy! Kill it!
extends Hittable
class_name Enemy

signal died

## Maximum health
@export var max_health: int = 1

## Current health
@onready var health := max_health:
  set(value):
    health = clamp(value, 0, max_health)
    if health == 0:
      died.emit() # voodoo magic makes this signal connect to die()
      # die()

func hit(damage: int) -> void:
  health -= damage

func die() -> void:
  Utils.instance_scene_on_main(preload("res://fx/enemy_death.tscn"), global_position)
  queue_free()
