extends Level

func _ready() -> void:
	const wm := {
		Vector2i.UP: [Vector2i(7, 0), Vector2i(8, 0)],
		Vector2i.DOWN: [Vector2i(7, 15), Vector2i(8, 15)],
		Vector2i.LEFT: [Vector2i(0, 7), Vector2i(0, 8)],
		Vector2i.RIGHT: [Vector2i(15, 7), Vector2i(15, 8)]
	}
	var terrain: Array[Vector2i] = []
	for wall in Maze.tile_4b_to_wall_array(enabled_walls):
		terrain.append_array(wm[wall])
	set_cells_terrain_connect(0, terrain, 0, 0, true)
	super()

