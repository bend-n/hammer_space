extends AudioStreamPlayer


var track := preload("res://assets/music/music.ogg")

func _ready() -> void:
	finished.connect(p)

func p() -> void:
	stream = track
	pitch_scale = 1 + randf_range(-0.05, 0.05)
	volume_db = -20
	play()

func s() -> void:
	var tween := create_tween()
	tween.tween_property(self, ^"volume_db", -200, 5)
	tween.finished.connect(func stop() -> void: stop())
