extends Area2D

@export var damage: int = 1

signal hit_enemy

func _on_area_entered(hurtbox: Hurtbox) -> void:
  (hurtbox.owner as Hittable).hit(damage)
  hit_enemy.emit()

func _ready() -> void:
  area_entered.connect(_on_area_entered)
