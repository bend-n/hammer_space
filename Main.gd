extends Node2D

var maze: Maze


func _on_level_manager_world_generated(p_maze: Maze) -> void:
  maze = p_maze
