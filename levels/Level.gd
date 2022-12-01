## A Level.
extends TileMap
class_name Level

@icon("./level_icon.svg")

const BlockDoor_scn := preload("res://world/door/block_door.tscn")
const Door_scn := preload("res://world/door/door.tscn")
const OneWayPlatform_scn := preload("res://world/one_way_platform.tscn")

## The enabled walls. [url=https://kidscancode.org/blog/img/cells_4bit.png]4bit[/url]
@export_range(0, 15) var enabled_walls := 15

const rot_map := {Vector2i.LEFT: PI, Vector2i.RIGHT: 0, Vector2i.DOWN: PI / 2, Vector2i.UP: -PI / 2}  # 180  # 90  # -90

var completed := false:
	set(value):
		if not is_inside_tree() and value == true:
			completed = value
		else:
			push_error("no")

@onready var enemys := $Enemys.get_children() if not completed else []
@onready var enemyqty := enemys.size() if not completed else 0
@onready var has_enemys := enemyqty != 0

@onready var blockdoors: Node2D
@onready var doors: Node2D = create_node(&"doors")


## Utility fuction to create a [Node2D]
func create_node(p_name: StringName) -> Node2D:
	var n := Node2D.new()
	n.position = Vector2.ZERO
	n.name = p_name
	add_child(n)
	move_child(n, 0)
	return n


func _ready():
	collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_HIDE
	var door_array := Maze.tile_4b_to_path_array(enabled_walls)

	if completed:
		($Enemys as Node2D).queue_free()
	if !door_array.is_empty():
		if has_enemys:
			blockdoors = create_node(&"block_doors")

		for door_p in door_array:
			var door := add_door(door_p)
			if has_enemys:
				add_block_door(door)

		if Vector2i.DOWN in door_array:
			var n := create_node(&"one_way_platform")
			n.position = Vector2(128, 243)
			var p: OneWayPlatform = OneWayPlatform_scn.instantiate()
			n.call_deferred(&"add_child", p)

	for enemy in enemys:
		enemy.died.connect(_on_enemy_died)

## Add a [Door] for given direction.
func add_door(dir: Vector2i) -> Door:
	var d := Door_scn.instantiate()
	var v := Vector2i(128, 128)  # center
	d.rotation = rot_map[dir]
	d.position = Vector2(v + (v * dir)).move_toward(v, 16)
	d.dir = dir
	doors.add_child(d)
	return d

## Add a [BlockDoor] on top of a [Door]
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

## Opens all doors
func open_doors() -> void:
	var block_doors := blockdoors.get_children()
	for bloc_door in block_doors:
		bloc_door.open()
