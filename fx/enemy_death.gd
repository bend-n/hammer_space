extends Node2D

const DustFx := preload("./dust.tscn")

func _ready() -> void:
	randomize()
	var randv := func randv(): return Vector2(randf_range(-10, 10), randf_range(-10, 10))
	for i in range(10):
		var inst := Utils.instance_on_main(DustFx.instantiate()) as Node2D
		inst.global_position = global_position + randv.call()
		if i == 9:
			inst.tree_exited.connect(queue_free)
