extends Popuppable

func open() -> void:
	$anim.play(&"death")
	super()

func _ready() -> void:
	set_process_unhandled_input(false)