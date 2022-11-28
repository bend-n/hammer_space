extends Node2D

const DustFx := preload("./dust.tscn")

func _ready() -> void:
	# print(global_position)
	randomize()
	# print_stack()
	# get_tree().paused = true
	var randv := func randv(): return Vector2(randf_range(-10, 10), randf_range(-10, 10))
	for i in range(10):
		var inst := Utils.instance_scene_on_main(DustFx, global_position + randv.call())
		if i == 9:
			inst.tree_exited.connect(queue_free)
