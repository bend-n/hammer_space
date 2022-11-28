extends HBoxContainer
class_name CaretOptionButton

signal changed(current_option: int)

@onready var button: Button = $button as Button
@export var options: PackedStringArray = []
@export var current_option: int = 0:
	set(val):
		current_option = wrapi(val, 0, len(options))
		if not button: return
		button.text = options[current_option]
		changed.emit(current_option)

func _ready() -> void:
	current_option = current_option

func sub() -> void:
	current_option -= 1

func add() -> void:
	current_option += 1
