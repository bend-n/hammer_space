## Draws a 2D trail using a [Line2D].
class_name Trail2D
extends Line2D

@icon("./trail2d_icon.svg")

## Enable or disable the trail
@export var emitting := true:
		set(p_emitting):
				emitting = p_emitting
				if not is_inside_tree():
						await ready

				if emitting:
						clear_points()
						_points_creation_time.clear()
						_last_point = to_local(target.global_position)

## Resolution. Smaller = more points
@export var resolution := 2.0

## The lifetime for each point
@export var lifetime := 0.5

## Maximum number of points
@export var max_points := 100

## Optional path to the target node to follow. If not set, the instance follows its parent.
@onready @export var target: Node2D

var _points_creation_time: PackedFloat32Array = []
var _last_point := Vector2.ZERO
var _clock := 0.0

func _ready() -> void:
		if not target:
				target = get_parent() as Node2D

		joint_mode = Line2D.LINE_JOINT_BEVEL
		top_level = true
		clear_points()
		position = Vector2.ZERO
		_last_point = to_local(target.global_position)


func _process(delta: float) -> void:
		_clock += delta
		remove_older()

		if not emitting:
				return

		# Adding new points if necessary.
		var desired_point := (target.global_position)
		var distance: float = _last_point.distance_to(desired_point)
		if distance > resolution:
				add_timed_point(desired_point, _clock)


## Creates a new point and stores its creation time.
func add_timed_point(point: Vector2, time: float) -> void:
		add_point(point)
		_points_creation_time.append(time)
		_last_point = point
		if get_point_count() > max_points:
				remove_first_point()


## Removes the first point in the line and the corresponding time.
func remove_first_point() -> void:
		if get_point_count() > 1:
				remove_point(0)
		_points_creation_time.remove_at(0)


## Remove points older than [code]lifetime[/code].
func remove_older() -> void:
		for creation_time in _points_creation_time:
				var delta := _clock - creation_time
				if delta > lifetime:
						remove_first_point()
				# Points in `_points_creation_time` are ordered from oldest to newest so as soon as a point
				# isn't older than `lifetime`, we know all remaining points should stay as well.
				else:
						break
