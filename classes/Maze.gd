## Creates a maze using the [url=https://en.wikipedia.org/wiki/Maze_generation_algorithm#Randomized_depth-first_search]recursive backtracker algorithm[/url].
extends Resource
class_name Maze

## This mazes size.
var size: Vector2i

## The maze, in a 2d array.
## Type: [Array][[Array][[PackedInt32Array]].
var maze := []

## The north constant.
const N := 1

## The east constant.
const E := 2

## The south constant.
const S := 4

## The west constant.
const W := 8

## The N E S W mappings to UP RIGHT DOWN LEFTtr`1`
const cell_walls := {Vector2i.UP: N, Vector2i.RIGHT: E, Vector2i.DOWN: S, Vector2i.LEFT: W}
const _dirs := [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

## The image representation of this maze.
var image: Image = null:
  get:
    if not image:
        _gen_image()
    return image


func _init(p_size: Vector2i) -> void:
    size = p_size
    generate()
    erase_walls()

## Get a maze cells value.
func get_cellv(cell: Vector2i) -> int:
    return maze[cell.y][cell.x]

## Turns a 4b tile into a array of walls. [code]4[/code] => [code][Vector2i.DOWN][/code].
static func tile_4b_to_wall_array(tile_4b: int) -> Array[Vector2i]:
    var array: Array[Vector2i] = []
    for dir in _dirs:
        if tile_4b & cell_walls[dir]:
            array.append(dir)
    return array


## Turns a 4b tile into a array of paths. [code]4[/code] => [code][Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT][/code].
static func tile_4b_to_path_array(tile_4b: int) -> Array[Vector2i]:
    var array: Array[Vector2i] = []
    for dir in cell_walls.keys():
        if not tile_4b & cell_walls[dir]:
            array.append(dir)
    return array


func _check_neighbours(cell: Vector2i, unvisited: Array[Vector2i]) -> Array[Vector2i]:
    # checks if neighbour is visited.
    # returns array of unvisited neighbours.
    var list: Array[Vector2i] = []
    for n in cell_walls.keys():
        if cell + n in unvisited:
            list.append(cell + n)
    return list


func _set_cellv(cell: Vector2i, v: int) -> void:
    maze[cell.y][cell.x] = v

## Generates the maze using the [url=https://en.wikipedia.org/wiki/Maze_generation_algorithm#Randomized_depth-first_search]recursive backtracker algorithm[/url].
func generate() -> void:
    randomize()
    var unvisited: Array[Vector2i] = []
    var stack: Array[Vector2i] = []

    # fill maze
    maze.clear()
    for x in range(size.x):
        var row: PackedInt32Array = []
        for y in range(size.y):
            row.append(N|E|S|W)
            unvisited.append(Vector2i(x, y))
        maze.append(row)

    var current := Vector2i(0, 0)
    unvisited.erase(current)

    # recurive backtracking algorithm
    while unvisited.size() > 0:
        # check neighbours of current cell.
        var neighbours := _check_neighbours(current, unvisited)

        # if neighbours exist, pick one at random and move in that direction.
        # remove wall between current cell and neighbour cell.
        if neighbours.size() > 0:
            var next := neighbours[randi() % neighbours.size()]
            stack.append(current)

            # remove wall from both cells.
            var dir := next - current
            var current_walls: int = get_cellv(current) - cell_walls[dir]
            var next_walls: int = get_cellv(next) - cell_walls[-dir]
            _set_cellv(current, current_walls)
            _set_cellv(next, next_walls)
            current = next
            unvisited.erase(current)
        elif stack:
            # if neighbours don't exist, retrieve new current from stack.
            current = stack.pop_back()

## Randomly remove walls. Prefers deleting 3 and 2 walled cells.
func erase_walls() -> void:
    randomize()
    const three_walls: Array[int] = [7, 11, 13, 14]
    const two_walls: Array[int] = [3, 5, 6, 9, 10, 12]

    for x in range(size.x):
        for y in range(size.y):
            if maze[y][x] in three_walls or maze[x][y] in two_walls or randi() % 3 == 0:
                var cell := Vector2i(x, y)
                var i := randi() % 4
                for _i in range(4):
                    var n: Vector2i = cell_walls.keys()[i]
                    i = wrapi(i + _i, 0, 3)
                    if get_cellv(cell) & cell_walls[n]:
                        var n_cell := (cell + n)
                        if n_cell.x > size.x - 1 or n_cell.y > size.y - 1 or n_cell.x < 0 or n_cell.y < 0:
                            continue
                        var walls: int = get_cellv(cell) - cell_walls[n]
                        var n_walls: int = get_cellv(n_cell) - cell_walls[-n]
                        if (
                            (x == 0 and walls & W)
                            or (y == 0 and walls & N)
                            or (x == size.x and walls & E)
                            or (y == size.y and walls & S)
                            or (n_cell.x == 0 and n_walls & W)
                            or (n_cell.y == 0 and n_walls & N)
                            or (n_cell.x == size.x and n_walls & E)
                            or (n_cell.y == size.y and n_walls & S)
                        ):
                            continue
                        if walls in three_walls or n_walls in three_walls:
                            continue
                        _set_cellv(cell, walls)
                        _set_cellv(n_cell, n_walls)
                        break


func _gen_image() -> void:
    var img = Image.create(size.x * 3, size.y * 3, false, Image.FORMAT_L8)
    var position := Vector2i.ZERO
    for i in len(maze):
        for j in len(maze[i]):
            var paths := Maze.tile_4b_to_path_array(maze[i][j])
            if not paths.is_empty():
                var middle := position + Vector2i.ONE
                img.set_pixelv(middle, Color.WHITE)
                for path in paths:
                    img.set_pixelv(middle + path, Color.WHITE)
            position.x += 3
        position.y += 3
        position.x = 0
    image = img
