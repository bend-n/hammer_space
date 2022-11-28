extends Popuppable


func _ready() -> void:
	open()
	var buttons := get_tree().get_nodes_in_group(&"button")
	var play_sound := func plays() -> void: randomize() ; SoundManager.play("click", -10, randf_range(.9, 1.1))
	for butt in buttons:
		if butt is Button:
			butt.pressed.connect(play_sound)
		elif butt is RemapButton:
			butt.button.pressed.connect(play_sound)
			butt.clear.pressed.connect(play_sound)


func exit() -> void:
	pass
