## A hammer.
extends Area2D
class_name Hammer

@icon("res://assets/hammers/hammer01.png")

@onready var left_cast := $LeftCast as RayCast2D
@onready var right_cast := $RightCast as RayCast2D
@onready var target_cast := $TargetCast as RayCast2D
@onready var trail := $Trail as Trail2D
@onready var outline_shader := ($Sprite as Sprite2D).material as ShaderMaterial
@onready var target_finder := $TargetFinder as Area2D
@onready var hitbox := $Hitbox as Hitbox
@onready var hitbox_c := hitbox.get_child(0) as CollisionShape2D
@onready var c := $Collision as CollisionShape2D

## The current velocity
var velocity := Vector2.ZERO

## The direction to go in
var direction := Vector2.ZERO

## Acceleration
@export var acceleration := 100.0

## Maximum speed
@export var top_speed := 3.0

## The amount it can turn towards its target
@export var steer_force = 0.01

## The hit enum.
enum HITS {_a, _b, NONE, PLAYER, ENEMY}

## These nodes want to have their collision mask set to the current enemy.
@onready var hitmasks = [target_finder, hitbox, left_cast, right_cast, self, target_cast]

## Pick which layers to hit.
@export var hits: HITS = HITS.PLAYER:
	set(value):
		for node in hitmasks:
			node.set_collision_mask_value(hits, false)
		hits = value
		hitbox.monitoring = hits != HITS.NONE
		target_finder.monitoring = not is_instance_valid(target)
		if value == HITS.NONE:
			return
		for node in hitmasks:
			node.set_collision_mask_value(hits, true)
		hitbox_c.shape.size.x = 8 if hits == HITS.ENEMY else 1
		c.shape.size.x = 8 if hits == HITS.ENEMY else 1

## The amount of time before gravity kicks in.
@export var lifetime := 3.0

## The gravity
@export var grav := 4.0

## The target
var target: Node2D = null

func _ready() -> void:
	unhighlight()
	hits = hits

## Lerps direction towards [param to].
func dirlerp(to: Vector2) -> void:
	direction = lerp(direction, to, steer_force * clampf(lifetime, 0, 1))

## Moves the direction towards the target.
func seek() -> void:
	if is_instance_valid(target):
		target_cast.force_raycast_update()
		if is_enemy(target_cast.get_collider()): # course is good, dont touch anything
			return
		dirlerp(global_position.direction_to(target.global_position))
		anticrash()
	elif target_finder.monitoring == false:
		target = null
		target_finder.monitoring = true

func is_enemy(n) -> bool:
	if is_instance_valid(target) and is_instance_valid(n) and n.get_class() == target.get_class(): return true
	return false

## Tries not to crash.
func anticrash() -> void:
	var is_wall := func is_wall(ray: RayCast2D) -> bool:
		ray.force_raycast_update()
		return not is_enemy(ray.get_collider())

	var results: Array[bool] = [is_wall.call(left_cast), is_wall.call(right_cast)]
	if results.count(true) == 2: return # resign to our fate

	for i in range(2):
		if results[i]:
			dirlerp(direction.rotated(0.174 if i == 0 else -0.174))

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

# we crashed
func _on_body_entered(_body: Node2D) -> void:
	trail.emitting = false
	target_finder.monitoring = false
	hitbox.monitoring = false
	set_collision_layer_value(7, true)
	global_position += velocity.limit_length(1)  # go into the wall a little
	velocity = Vector2.ZERO
	hits = HITS.NONE
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


func _on_target_finder_node_entered(_n: Node2D) -> void:
	if target != null:
		push_error("Huh.")
		return
	var bods: Array[Node2D] = target_finder.get_overlapping_bodies() + target_finder.get_overlapping_areas()
	var space = get_world_2d().direct_space_state
	var current := {closest = null, dist = 0}
	for bod in bods:
		var res := space.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, bod.global_position.move_toward(global_position, .1), pow(2, 1-1)))
		if res.is_empty():
			var dist := global_position.distance_to(bod.global_position)
			if current.dist < dist:
				current.dist = dist
				current.closest = bod
	if current.closest != null:
		target = current.closest
		target_finder.set_deferred(&"monitoring", false)
