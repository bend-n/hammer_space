## A hammer.
extends Area2D
class_name Hammer

@icon("res://assets/hammers/hammer01.png")

## The current velocity
var velocity := Vector2.ZERO

## The direction to go in
var direction := Vector2.ZERO

## Acceleration
@export var acceleration := 100.0

## Maximum speed
@export var top_speed := 3.0

## The amount it can turn towards its target
@export var steer_force = 0.05

## To hit the player
@export var hit_player := true

## To hit the enemys
@export var hit_enemys := false

## The amount of time before gravity kicks in.
@export var lifetime := 3.0

## The gravity
@export var grav := 4.0

## The target
var target: Node2D = null

@onready var trail := $Trail as Trail2D
@onready var outline_shader := ($Sprite as Sprite2D).material as ShaderMaterial
@onready var target_finder := $TargetFinder as Area2D
@onready var hitbox := $Hitbox as Hitbox


func _ready() -> void:
	set_masks()


## Sets the collision masks.
func set_masks() -> void:
	set_collision_mask_value(3, hit_player)
	set_collision_mask_value(4, hit_enemys)
	target_finder.set_collision_mask_value(3, hit_player)
	target_finder.set_collision_mask_value(4, hit_enemys)
	hitbox.collision_mask = target_finder.collision_mask
	target_finder.monitoring = not is_instance_valid(target)
	hitbox.monitoring = hit_player || hit_enemys


## Moves the direction towards the target.
func seek() -> void:
	if is_instance_valid(target):
		direction = lerp(
			direction, global_position.direction_to(target.global_position), steer_force * clampf(lifetime, 0, 1)
		)
	elif target_finder.monitoring == false:
		target = null
		target_finder.monitoring = true


## Highlights this hammer. See also [method unhighlight].
func highlight() -> void:
	outline_shader.set_shader_parameter(&"line_width", .75)


## Un-highlights this hammer. See also [method highlight].
func unhighlight() -> void:
	outline_shader.set_shader_parameter(&"line_width", 0)


func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime < 0:
		velocity.y += grav * delta
	else:
		seek()
		velocity += (direction * acceleration * delta)
		if velocity.y < 0:
			velocity.y = lerpf(velocity.y, 0, .1)  # hard to move up
	velocity.x = clampf(velocity.x, -top_speed, top_speed)
	velocity.y = clampf(velocity.y, -top_speed, top_speed)
	rotation = velocity.angle() + PI / 2  # face forward
	global_position += velocity


func _on_body_entered(_body: Node2D) -> void:
	trail.emitting = false
	target_finder.monitoring = false
	hitbox.monitoring = false
	set_collision_layer_value(7, true)
	global_position += velocity.limit_length(1)  # go into the wall a little
	velocity = Vector2.ZERO
	target = null
	steer_force = 0.05
	lifetime = 3
	set_physics_process(false)
	trail.clear_points()


## Throws this [Hammer].
func throw(p_direction: Vector2) -> void:
	set_collision_layer_value(7, false)
	direction = p_direction
	trail.emitting = true
	set_physics_process(true)
	set_masks()


func _on_target_finder_node_entered(n: Node2D) -> void:
	target = n
	target_finder.set_deferred(&"monitoring", false)
