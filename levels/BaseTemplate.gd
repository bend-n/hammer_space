extends TileMap
class_name Level

const BlockDoor_scn := preload("res://world/door/block_door.tscn")
const Door_scn := preload("res://world/door/door.tscn")
const OneWayPlatform_scn := preload("res://world/one_way_platform.tscn")

const ALL_DOORS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

@export_range(0, 15) var enabled_walls := 0  # https://kidscancode.org/blog/img/cells_4bit.png

const rot_map := {Vector2i.LEFT: PI, Vector2i.RIGHT: 0, Vector2i.DOWN: PI / 2, Vector2i.UP: -PI / 2}  # 180  # 90  # -90

@onready var enemys := $Enemys.get_children()
@onready var enemyqty := $Enemys.get_child_count()
@onready var has_enemys := enemyqty != 0

@onready var blockdoors: Node2D
@onready var doors: Node2D = create_node(&"doors")


func create_node(p_name: StringName) -> Node2D:
	var n := Node2D.new()
	n.position = Vector2.ZERO
	n.name = p_name
	add_child(n)
	return n


func _ready():
	var wall_array := Maze.tile_4b_to_wall_array(enabled_walls)

	if len(wall_array) != 4:
		var door_array := Util.sub(ALL_DOORS, wall_array)
		if Vector2i.DOWN in door_array:
			var p: OneWayPlatform = OneWayPlatform_scn.instantiate()
			p.position = Vector2(128, 243)
			call_deferred(&"add_child", p)

		if has_enemys:
			blockdoors = create_node(&"block_doors")

		for door_p in door_array:
			var door := add_door(door_p)
			if has_enemys:
				add_block_door(door)

	for enemy in enemys:
		enemy.connect(&"died", _on_enemy_died)


func add_door(dir: Vector2i) -> Door:
	var d := Door_scn.instantiate()
	var v := Vector2i(128, 128)  # center
	d.rotation = rot_map[dir]
	d.position = Vector2(v + (v * dir)).move_toward(v, 16)
	d.dir = dir
	doors.add_child(d)
	return d


func add_block_door(door: Door) -> BlockDoor:
	var d := BlockDoor_scn.instantiate()
	d.rotation = door.rotation
	d.position = door.position.move_toward(Vector2(128, 128), -8)
	blockdoors.add_child(d)
	return d


func _on_enemy_died() -> void:
	enemyqty -= 1
	if enemyqty == 0:
		open_doors()


func open_doors() -> void:
	var block_doors := blockdoors.get_children()
	for bloc_door in block_doors:
		bloc_door.open()
