## A hammer.
extends Area2D
class_name Hammer

@icon("res://assets/hammers/hammer01.png")

## The current velocity
var velocity := Vector2.ZERO

## The direction to go in
var direction := Vector2.ZERO

## Acceleration
@export var acceleration := 100

## Maximum speed
@export var top_speed := 200

## The amount it can turn towards its target in radians
@export var steer_force = 0.05

## The target
var target: Node2D = null

## To hit the player
var hit_player := true

## To hit the enemys
var hit_enemys := false

@onready var trail := $Trail as Trail2D
@onready var outline_shader := ($Sprite as Sprite2D).material as ShaderMaterial

func _ready() -> void:
  set_collision_mask_value(3, hit_player)
  set_collision_mask_value(4, hit_enemys)

func seek() -> void:
  if target:
    direction = direction + (global_position.direction_to(target.global_position) - direction) * steer_force

func highlight() -> void:
  outline_shader.set_shader_parameter(&"line_width", .75)

func unhighlight() -> void:
  outline_shader.set_shader_parameter(&"line_width", 0)

func _physics_process(delta: float) -> void:
  seek()
  velocity = (direction * acceleration * delta).limit_length(top_speed)
  rotation = velocity.angle() + PI/2 # face forward
  global_position += velocity

func _on_body_entered(_body: Node2D) -> void:
  trail.clear_points()
  global_position += velocity # go into the wall a little
  set_physics_process(false)
