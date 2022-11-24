extends Enemy

@export var ACCELERATION := 3
@export var MAX_SPEED := 32
@export var FRICTION := .8
@export var SHOT_COOLDOWN := 1
@onready @export var muzzle: Marker2D
@onready @export var floorcast: RayCast2D
@onready @export var animator: AnimationPlayer
@onready @export var player_cast: ShapeCast2D

var axis := 0
var current_dir := 0
enum States {MOVE, FIRE}
var state := States.MOVE
var bullet_timer: SceneTreeTimer = null

func _ready() -> void:
  up_direction = global_position.direction_to(muzzle.global_position).round()
  axis = 1 if up_direction.x != 0 else 0
  current_dir = -1 if randi() % 2 == 0 else 1


func _physics_process(_delta: float) -> void:
  match state:
    States.MOVE:
      var dir := brain()
      animator.play(&"normal")

      velocity[axis] += dir * ACCELERATION
      velocity[axis] = clampf(velocity[axis], -MAX_SPEED, MAX_SPEED)
      if (dir == 0):
        velocity[axis] = lerpf(velocity[axis], 0, FRICTION)
      floorcast.position.x = 0 + (dir * 10)
      move_and_slide()
    States.FIRE:
      animator.play(&"fire")
      await animator.animation_finished
      state = States.MOVE


func fire() -> void:
  var hammer: Hammer = Utils.instance_scene_on_level(Utils.get_hammer(), muzzle.global_position)
  hammer.steer_force = 0.01 # cheat
  hammer.target = Globals.player
  hammer.direction = up_direction
  bullet_timer = get_tree().create_timer(SHOT_COOLDOWN)
  player_cast.enabled = false

func brain() -> float:
  var dir := 0.0
  if bullet_timer == null or bullet_timer.time_left < 0:
    if not player_cast.enabled:
      bullet_timer = null
      player_cast.force_shapecast_update()
      player_cast.enabled = true
    for i in player_cast.get_collision_count():
      if player_cast.get_collider(i) is Player:
        if player_cast.get_collision_count() != 1:
          player_cast.target_position.y = -((global_position.y-Globals.player.global_position.y) + 30)
          player_cast.force_shapecast_update()
          player_cast.target_position.y = -170
        if player_cast.get_collision_count() == 1:
          state = States.FIRE
        break
  if not state == States.FIRE:
    if is_on_wall():
      dir = -get_wall_axis()
    elif not floorcast.is_colliding():
      dir = -current_dir
    else:
      dir = current_dir
    current_dir = roundi(dir)
  return dir

func get_wall_axis() -> int:
  var left := up_direction
  left[axis] = -1
  var right := up_direction
  right[axis] = 1
  var is_right_wall := test_move(transform, left)
  var is_left_wall := test_move(transform, right)
  return int(is_left_wall) - int(is_right_wall)
