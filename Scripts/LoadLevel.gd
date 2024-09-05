class_name LoadLevel
extends Button

@export var level: PackedScene = preload("res://Levels/LevelSelect.tscn")

func load_level() -> void:
	GameManager.load_level_from_packed(level)
