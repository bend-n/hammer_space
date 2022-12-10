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

## The current level
var current_level: TileMap
@export var start: PackedScene
@export var player: Player
@onready var main := get_parent() as Node2D
var lvl_position := Vector2i(-1, -1)

## Timer used for debouncing multiple door enters. (some kind of physics bug there is probably a tracker for but i havent found it)
var t: SceneTreeTimer

## type: PackedScene[14][∞]
var levels := []

func _init() -> void:
	Globals.levelmanager = self

func _ready() -> void:
	populate_levels()
	gen_map()
	Events.change_level.connect(go)
	if OS.is_debug_build():
		# show sorted levels
		for i in len(levels):
			print(i, ":", " [")
			for l in levels[i]:
				print(l.resource_path.indent("\t"))
			print("],")

		# show the map
		var string := ""
		for row in map:
			for item in row:
				if "Start" in item.resource_path:
					string += "na "
				else:
					string += "%02d " % item.get_state().get_node_property_value(0, 1)
			string += "\n"
		print(string)

		# show the maze (for visual discrepancy parsing)
		string = ""
		for row in maze.maze:
			for item in row:
				string += "%02d " % item
			string += "\n"
		print(string)
	lvl_position = size / 2
	current_level = start.instantiate()
	current_level.enabled_walls = maze.get_cellv(lvl_position)
	main.call_deferred(&"add_child", (current_level))

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


# apparently lambdas cant do it
func __inner_populate_loop(path := "res://levels/rand"):
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if dir.current_is_dir():
			__inner_populate_loop(path.path_join(file_name))
		else:
			file_name = file_name.trim_suffix('.remap') # <---- NEW
			var level: PackedScene = load(path.path_join(file_name)) as PackedScene
			# Split levels into wall groups groups.
			levels[level.get_state().get_node_property_value(0, 1)].append(level)
		file_name = dir.get_next()

## Populates the levels array
func populate_levels() -> void:
	levels.clear()
	levels = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
	__inner_populate_loop()


## Generates the maze.
func gen_map() -> void:
	maze = Maze.new(size)
	maze.image.save_png("res://maze.png")
	lvl_position = size / 2
	map.clear()
	for row in maze.maze:
		var map_row: Array[PackedScene] = []
		for i in row:
			map_row.append(levels[i][randi() % len(levels[i])])
		map.append(map_row)
	map[lvl_position.x][lvl_position.y] = start
	world_generated.emit(maze)

