extends Node
class_name LevelManager

signal world_generated(maze: Maze)

var map := []

const lvl_path_fmt := "res://levels/rand/%s.tscn"
@export var levels: Array[PackedScene]
@export var size := Vector2i(6, 6)
@export var current_level: TileMap  # ASSIGN TO START
@export var player: Player
@onready var main := get_parent()
var lvl_position := Vector2i(-1, -1)
var t: SceneTreeTimer

var sorted := [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]] # Array[Array[PackedScene]] [[0..][1..]...[15..]]


func go(to: Vector2i) -> void:
  if t and t.time_left > 0:
    print("skipping door enter")
    return
  t = get_tree().create_timer(0.1)
  lvl_position += to
  current_level.queue_free()
  current_level = map[lvl_position.y][lvl_position.x].instantiate()
  var v := Vector2i(128, 128)  # center
  player.position = Vector2(v - (v * to)).move_toward(v, 24)
  player.velocity = Vector2.ZERO
  prints("welcome to", current_level.name)
  main.call_deferred(&"add_child", current_level)


func print_map_pretty() -> void:
  var string := ""
  for row in map:
    for item in row:
      string += str(item.get_state().get_node_name(0)).substr(0, 2) + " "
    string += "\n"
  print(string)


# split levels into https://kidscancode.org/blog/img/cells_4bit.png
func sort_levels():
  for level in levels:
    var n: int = 0 if level.get_state().get_node_property_count(0) == 1 else level.get_state().get_node_property_value(0,1)
    sorted[n].append(level)


func _ready() -> void:
  gen_map()
  lvl_position = size / 2
  Events.connect(&"change_level", go)
  print_map_pretty()


func gen_map() -> void:
  sort_levels()
  var maze := Maze.new(size)
  maze.image().save_png("res://maze.png")
  lvl_position = size / 2
  map.clear()
  for row in maze.maze:
    var map_row: Array[PackedScene] = []
    for i in row:
      map_row.append(sorted[i][randi() % len(sorted[i])])
    map.append(map_row)
  map[lvl_position.x][lvl_position.y] = preload("res://levels/Start.tscn")
  emit_signal(&"world_generated", maze)
