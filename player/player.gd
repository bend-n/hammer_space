extends Hittable
class_name Player

const DustEffect := preload("res://fx/dust.tscn")
const JumpEffect := preload("res://fx/jump.tscn")
const DoubleJumpEffect := preload("res://fx/double_jump.tscn")
const WallJumpEffect := preload("res://fx/wall_dust.tscn")

signal hp_changed(health: int)


## Death overlay.
@export var death: Popuppable

## Accel
@export var accel := 512

## Topspeed
@export var top_speed := 64

## Jump force
@export var jump_force := 150

## The topspeed at which we slide down the wall
@export var max_wall_slide_fall_speed := 110

## The standard speed at which we slide down the wall
@export var wall_slide_fall_speed := 42

## Friction
@export var frict := 0.25

## How much movement control to have in the air
@export var air_movement_modifier := 1.2

## Max hp
@export var max_health := 10

@onready var sprite := $Sprite as Sprite2D
@onready var anims := $Player as AnimationPlayer
@onready var pickup_area := $PickupArea as Area2D
@onready var aim_gizmo := $AimGizmo as AimGizmo

## The coyote jump timer.
## Allows you to jump after leaving the ground if the timer has not run out.
@onready var coyote := $CoyoteJump as Timer
@onready var GRAVITY: float = ProjectSettings.get_setting(&"physics/2d/default_gravity")

func _init() -> void:
	Globals.player = self

func _exit_tree() -> void:
	Globals.player = null

## State enum.
enum State { MOVE, WALL_SLIDE, STOP }

## Aiming the hammer.
var aiming := false

## Can we double jump now?
var double_jump := true

## The current state, one of the State enums.
var state := State.MOVE

## Have we just jumped?
var just_jumped := false

## The hammer we carry.
var current_hammer: Hammer = null

## The last highlit hammer.
var last_highlit: Hammer = null

var health := max_health:
	set(hp):
		health = hp
		hp_changed.emit(hp)
		if hp <= 0:
			death.open()
			queue_free()


func _physics_process(delta: float) -> void:
	just_jumped = false
	match state:
		State.STOP:
			velocity = Vector2.ZERO
			play(&"idle")
		State.MOVE:
			var input := Input.get_axis(&"left", &"right")
			if aiming:
				input = 0
			elif not is_on_floor():
				input *= air_movement_modifier
			apply_force(input, delta)
			apply_friction(input)

			jump_check()

			apply_gravity(delta)

			animate(input)
			move()
			wall_slide_check()
		State.WALL_SLIDE:
			play(&"wall_slide")
			var wall_axis := get_wall_axis()
			if wall_axis != 0:
				sprite.scale.x = wall_axis

			wall_slide_jump_check(wall_axis)
			wall_slide_drop(delta)
			move()
			wall_detatch(wall_axis, delta)
	check_throw()
	hammer_highlight()
	hammer_pickup()
	hammer_move()

## Creates floor dust.
func dust() -> void:
	var dust_position := global_position
	dust_position.x += randf_range(-4, 4)
	Utils.instance_scene_on_main(DustEffect, dust_position)
	SoundManager.play("step", -20)

## Applys gravity.
func apply_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.y = minf(velocity.y, jump_force)

## Applys force with the [param input] of the player.
func apply_force(input: float, delta: float) -> void:
	if input != 0:
		velocity.x += input * accel * delta
		velocity.x = clampf(velocity.x, -top_speed, top_speed)

## Applys friction to the player.
func apply_friction(input: float) -> void:
	if input == 0 and not is_zero_approx(velocity.x) and is_on_floor():
		velocity.x = lerpf(velocity.x, 0, frict)

func hammer_highlight() -> void:
	if not current_hammer:
		var unhighlight := func unhighlight() -> void:
			if is_instance_valid(last_highlit):
				last_highlit.unhighlight()
				last_highlit = null
		var hamms := pickup_area.get_overlapping_areas()
		if hamms.is_empty():
			unhighlight.call()
		elif not last_highlit in hamms:
			unhighlight.call()
			last_highlit = hamms[0]
			hamms[0].highlight()

func hammer_pickup() -> void:
	if Input.is_action_just_pressed("pickup") and is_instance_valid(last_highlit) and not current_hammer:
		last_highlit.unhighlight()
		current_hammer = last_highlit
		Globals.levelmanager.current_level.remove_child(current_hammer)
		current_hammer.position.y = -14
		add_child(current_hammer)
		move_child(current_hammer, 0)


func hammer_move() -> void:
	if current_hammer:
		current_hammer.position.x = 6 * sprite.scale.x
		current_hammer.rotation = 0.087 * sprite.scale.x

func check_throw() -> void:
	if current_hammer and Input.is_action_just_pressed("throw"):
		aim_gizmo.enabled = true
		aiming = true
		aim_gizmo.show()

## Plays animations for the move state.
func animate(input: float) -> void:
	if sign(input) != 0:
		sprite.scale.x = sign(input)

	if not is_on_floor():
		play(&"jump")
		return

	if velocity.x != 0:
		play(&"run", sign(velocity.x * sprite.scale.x))
	else:
		play(&"idle")

## Plays a [param anim] with a speed of [param speed].
## If speed is negative, animation plays backwards.
func play(anim: StringName, speed: float = 1.0) -> void:
	anims.play(anim, -1, speed)


## Checks if we should jump.
func jump_check() -> void:
	var want2jump := Input.is_action_just_pressed(&"jump")
	if want2jump and (is_on_floor() or coyote.time_left > 0):
		jump(jump_force)
		just_jumped = true
	else:
		if want2jump and velocity.y < -jump_force / 2:
			velocity.y = -jump_force / 2

		if want2jump and double_jump == true:
			jump(jump_force * .75)
			double_jump = false

## Jumps with [param force] force.
func jump(force: float) -> void:
	SoundManager.play("jump", -10)
	if double_jump:
		Utils.instance_scene_on_main(JumpEffect, global_position)
	else:
		Utils.instance_scene_on_main(DoubleJumpEffect, global_position)
	velocity.y = -force

## Uses the velocity to move_and_slide.
func move() -> void:
	var was_in_air := not is_on_floor()
	var was_on_floor := is_on_floor()
	var last_position := position
	var last_velocity := velocity
	move_and_slide()

	# landing
	if was_in_air and is_on_floor():
		velocity.x = last_velocity.x
		double_jump = true
		Utils.instance_scene_on_main(JumpEffect, global_position)

	# just left ground
	if was_on_floor and not is_on_floor() and not just_jumped:
		position.y = last_position.y
		coyote.start()
		Utils.instance_scene_on_main(JumpEffect, global_position)

## Checks if we should enter a wall slide.
func wall_slide_check():
	if not is_on_floor() and is_on_wall_only():
		state = State.WALL_SLIDE
		double_jump = true
		dust()

## Checks what wall we are against.
func get_wall_axis() -> int:
	var is_right_wall := test_move(transform, Vector2.RIGHT)
	var is_left_wall := test_move(transform, Vector2.LEFT)
	return int(is_left_wall) - int(is_right_wall)

## Checks if we should jump off the [param wall_axis].
func wall_slide_jump_check(wall_axis: int) -> void:
	if Input.is_action_just_pressed(&"jump"):
		velocity.x = wall_axis * top_speed
		velocity.y = -jump_force / 1.25
		state = State.MOVE
		wall_dust(wall_axis)
		SoundManager.play("jump", -10)

## Creates dust against the [param wall_axis].
func wall_dust(wall_axis: int) -> void:
	var dust_position = global_position + Vector2(wall_axis * 4, -2)
	var dust_fx := Utils.instance_scene_on_main(WallJumpEffect, dust_position) as Node2D
	dust_fx.scale.x = wall_axis


## Slides down the wall.
func wall_slide_drop(delta: float) -> void:
	var max_slide_speed := wall_slide_fall_speed
	if Input.is_action_pressed("down"):
		max_slide_speed = max_wall_slide_fall_speed
	velocity.y = min(velocity.y + GRAVITY * delta, max_slide_speed)

## Checks if we should detatch from the wall.
func wall_detatch(wall_axis: int, delta: float) -> void:
	var detached := false
	if aiming: return

	if Input.is_action_just_pressed("right"):
		velocity.x = accel * delta
		detached = true

	if Input.is_action_just_pressed("left"):
		velocity.x = -accel * delta
		detached = true

	if detached:
		state = State.MOVE
		wall_dust(wall_axis)

	if wall_axis == 0 or is_on_floor():
		state = State.MOVE

func hit(damage: int) -> void:
	health -= damage
	for pad in Input.get_connected_joypads():
		Input.start_joy_vibration(pad, .3 * damage, .3 * damage, .5)


## Disable the aim gizmo.
func disable_aim_gizmo() -> void:
	aiming = false
	aim_gizmo.enabled = false
	aim_gizmo.hide()

## Throws the hammer.
func throw(rot: float) -> void:
	remove_child(current_hammer)
	current_hammer.position = Vector2(0, -8) # center
	current_hammer.global_position = to_global(current_hammer.position)
	Globals.levelmanager.current_level.add_child(current_hammer)
	current_hammer.hits = Hammer.HITS.ENEMY
	current_hammer.throw(Vector2.from_angle(rot))
	SoundManager.play("throw", -15)
	current_hammer = null
	disable_aim_gizmo()
