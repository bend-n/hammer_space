extends Node
class_name LevelManager

signal world_generated(maze: Maze)

## One map to rule them all
var map := []

## The maze the map is generated from
var maze: Maze = null

## Stores the levels that the player has completed--killed all enemys--
## so that we can spawn the level without enemys when the palyer goes back
var completed_levels: Array[Vector2i] = []

## Maze size
@export var size := Vector2i(10, 10)

## ASSIGN TO Start.tscn
@export var current_level: TileMap
@export var start: PackedScene
@export var player: Player
@onready var main := get_parent() as Node2D
var lvl_position := Vector2i(-1, -1)

## Timer used for debouncing multiple door enters. (some kind of physics bug there is probably a tracker for but i havent found it)
var t: SceneTreeTimer

@export var levels: Array[PackedScene]

## type: PackedScene[15][∞]
var sorted := [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]

func _init() -> void:
	Globals.levelmanager = self

func _exit_tree() -> void:
	Globals.levelmanager = null

func _ready() -> void:
	gen_map()
	lvl_position = size / 2
	Events.change_level.connect(go)
	print_map_pretty()

## Goes to the next room in [param to] direction.
func go(to: Vector2i) -> void:
	completed_levels.append(lvl_position)
	if t and t.time_left > 0:
		print("skipping door enter")
		return
	t = get_tree().create_timer(0.1)
	lvl_position += to
	current_level.queue_free()
	current_level = map[lvl_position.y][lvl_position.x].instantiate() as TileMap
	var v := Vector2i(128, 128)  # center
	player.position = Vector2(v - (v * to)).move_toward(v, 24)
	player.velocity = Vector2.ZERO
	main.call_deferred(&"add_child", current_level)
	if lvl_position in completed_levels:
		current_level.completed = true
		prints("welcome back to", current_level.name)
	else:
		prints("welcome to", current_level.name)

## Prints out the map prettily.
## eg: [codeblock]
## 14 16 04 08 08 10
## 15 04 07 04 04 06
## 12 09 12 05 11 05
## 15 08 07 St 05 13
## 12 08 06 15 02 05
## 15 08 07 08 07 09
## [/codeblock]
func print_map_pretty() -> void:
	var string := ""
	for row in map:
		for item in row:
			string += str(item.get_state().get_node_name(0)).substr(0, 2) + " "
		string += "\n"
	print(string)

## Split levels into [url=https://kidscancode.org/blog/img/cells_4bit.png]4bit wall[/url] groups.
func sort_levels():
	for level in levels:
		# property idx 1 is the enabled walls
		# if prop is not overriden, default to 0
		var n: int = 0 if level.get_state().get_node_property_count(0) == 1 else level.get_state().get_node_property_value(0, 1)
		sorted[n].append(level)

## Generates the maze.
func gen_map() -> void:
	sort_levels()
	maze = Maze.new(size)
	maze.image.save_png("res://maze.png")
	lvl_position = size / 2
	map.clear()
	for row in maze.maze:
		var map_row: Array[PackedScene] = []
		for i in row:
			map_row.append(sorted[i][randi() % len(sorted[i])])
		map.append(map_row)
	map[lvl_position.x][lvl_position.y] = start
	world_generated.emit(maze)
