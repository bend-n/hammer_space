extends Resource
class_name Maze

const N := 1
const E := 2
const S := 4
const W := 8

# dict mapping direction to vectors.
const _cell_walls := {Vector2i(0, -1): N, Vector2i(1, 0): E, Vector2i(0, 1): S, Vector2i(-1, 0): W}

var _size: Vector2i = Vector2i(6, 6)

var maze := []


func _init(p_size: Vector2i) -> void:
    _size = p_size
    randomize()
    _make_maze()


func _check_neighbours(cell: Vector2i, unvisited: Array[Vector2i]) -> Array[Vector2i]:
    # checks if neighbour is visited.
    # returns array of unvisited neighbours.
    var list: Array[Vector2i] = []
    for n in _cell_walls.keys():
        if cell + n in unvisited:
            list.append(cell + n)
    return list


func get_cellv(cell: Vector2i) -> int:
    return maze[cell.y][cell.x]


func set_cellv(cell: Vector2i, v: int) -> void:
    maze[cell.y][cell.x] = v


func _make_maze() -> void:
    var unvisited: Array[Vector2i] = []
    var stack: Array[Vector2i] = []

    # fill maze
    maze.clear()
    for x in range(_size.x):
        var row: PackedInt32Array = []
        for y in range(_size.y):
            row.append(N | E | S | W)  #N|E|S|W = 15
            unvisited.append(Vector2i(x,y))
        maze.append(row)
    
    var current := Vector2i(0, 0)
    unvisited.erase(current)

    #recurive backtracking algorithm
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
            var current_walls: int = get_cellv(current) - _cell_walls[dir]
            var next_walls: int = get_cellv(next) - _cell_walls[-dir]
            set_cellv(current, current_walls)
            set_cellv(next, next_walls)
            current = next
            unvisited.erase(current)
        elif stack:
            # if neighbours don't exist, retrieve new current from stack.
            current = stack.pop_back()


static func tile_4b_to_wall_array(tile_4b: int) -> Array[Vector2i]:
    var array: Array[Vector2i] = []
    if tile_4b & N:
        array.append(Vector2i.UP)
    if tile_4b & E:
        array.append(Vector2i.RIGHT)
    if tile_4b & S:
        array.append(Vector2i.DOWN)
    if tile_4b & W:
        array.append(Vector2i.LEFT)
    return array

func image() -> Image:
    var img := Image.create(_size.x*3, _size.y*3, false, Image.FORMAT_L8)
    
    const ALL_DOORS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
    var position := Vector2i.ZERO
    for i in len(maze):
        for j in len(maze[i]):
            var walls := Maze.tile_4b_to_wall_array(maze[i][j])
            if len(walls) != 4:
                var paths := Util.sub(ALL_DOORS, walls)
                var middle := position + Vector2i.ONE
                # if len(paths) > 2:
                img.set_pixelv(middle, Color.WHITE)
                for path in paths:
                    img.set_pixelv(middle + path, Color.WHITE)
            position.x += 3
        position.y += 3
        position.x = 0
    return img