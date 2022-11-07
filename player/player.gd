extends CharacterBody2D
class_name Player

const DustEffect := preload("res://fx/dust.tscn")
const JumpEffect := preload("res://fx/jump.tscn")
const DoubleJumpEffect := preload("res://fx/double_jump.tscn")
const WallJumpEffect := preload("res://fx/wall_dust.tscn")

@export var ACCELERATION := 512
@export var MAX_SPEED := 64
@export var JUMP_FORCE := 150
@export var MAX_WALL_SLIDE_SPEED := 110
@export var WALL_SLIDE_SPEED := 42

@export var FRICTION := 0.25
@export var AIR_MOVEMENT_MODIFIER := 0.95

@onready var sprite := $Sprite
@onready var anims := $Player as AnimationPlayer
@onready var coyote := $CoyoteJump as Timer

@onready var GRAVITY: float = ProjectSettings.get_setting(&"physics/2d/default_gravity")

const FLOOR_MAX_ANGLE := deg_to_rad(46)


func _init() -> void:
	floor_max_angle = FLOOR_MAX_ANGLE


enum State { MOVE, WALL_SLIDE, STOP }

var double_jump := true
var state := State.MOVE
var just_jumped := false


func _physics_process(delta: float) -> void:
	just_jumped = false
	match state:
		State.STOP:
			velocity = Vector2.ZERO
			play(&"idle")
		State.MOVE:
			var input := Input.get_axis(&"left", &"right")
			apply_force(input, delta)
			apply_friction(input)

			jump_check()

			apply_gravity(delta)

			animate()
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


func dust() -> void:
	var dust_position := global_position
	dust_position.x += randf_range(-4, 4)
	Utils.instance_scene_on_main(DustEffect, dust_position)
	# SoundFx.play("Step", -20)


func apply_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.y = minf(velocity.y, JUMP_FORCE)


func apply_force(input: float, delta: float) -> void:
	if input != 0:
		velocity.x += input * ACCELERATION * delta
		velocity.x = clampf(velocity.x, -MAX_SPEED, MAX_SPEED)
		# if not is_on_floor():
		#     velocity.x *= AIR_MOVEMENT_MODIFIER


func apply_friction(input: float) -> void:
	if input == 0 and not is_zero_approx(velocity.x) and is_on_floor():
		velocity.x = lerpf(velocity.x, 0, FRICTION)


func animate() -> void:
	var facing = sign(get_local_mouse_position().x)
	if facing != 0:
		sprite.scale.x = facing

	if not is_on_floor():
		play(&"jump")
		return

	if velocity.x != 0:
		play(&"run", clampi(velocity.x * sprite.scale.x, -1, 1))
	else:
		play(&"idle")


func play(anim: StringName, speed: float = 1.0) -> void:
	anims.play(anim, -1, speed)


func jump_check() -> void:
	var want2jump := Input.is_action_just_pressed(&"jump")
	if want2jump and (is_on_floor() or coyote.time_left > 0):
		jump(JUMP_FORCE)
		just_jumped = true
	else:
		if want2jump and velocity.y < -JUMP_FORCE / 2:
			velocity.y = -JUMP_FORCE / 2

		if want2jump and double_jump == true:
			double_jump = false
			jump(JUMP_FORCE * .75)


func jump(force):
	# SoundFx.play("Jump", -20)
	if double_jump:
		Utils.instance_scene_on_main(JumpEffect, global_position)
	else:
		Utils.instance_scene_on_main(DoubleJumpEffect, global_position)
	velocity.y = -force


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


func wall_slide_check():
	if not is_on_floor() and is_on_wall_only():
		state = State.WALL_SLIDE
		double_jump = true
		dust()


func get_wall_axis() -> int:
	var is_right_wall := test_move(transform, Vector2.RIGHT)
	var is_left_wall := test_move(transform, Vector2.LEFT)
	return int(is_left_wall) - int(is_right_wall)


func wall_slide_jump_check(wall_axis) -> void:
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_axis * MAX_SPEED
		velocity.y = -JUMP_FORCE / 1.25
		state = State.MOVE
		wall_dust(wall_axis)
		# SoundFx.play("Jump", -20)


func wall_dust(wall_axis: int) -> void:
	var dust_position = global_position + Vector2(wall_axis * 4, -2)
	var dust_fx := Utils.instance_scene_on_main(WallJumpEffect, dust_position)
	dust_fx.scale.x = wall_axis


func wall_slide_drop(delta: float) -> void:
	var max_slide_speed = WALL_SLIDE_SPEED
	if Input.is_action_pressed("down"):
		max_slide_speed = MAX_WALL_SLIDE_SPEED
	velocity.y = min(velocity.y + GRAVITY * delta, max_slide_speed)


func wall_detatch(wall_axis: int, delta: float) -> void:
	var detached := false
	if Input.is_action_just_pressed("right"):
		velocity.x = ACCELERATION * delta
		detached = true

	if Input.is_action_just_pressed("left"):
		velocity.x = -ACCELERATION * delta
		detached = true

	if detached:
		state = State.MOVE
		wall_dust(wall_axis)

	if wall_axis == 0 or is_on_floor():
		state = State.MOVE
