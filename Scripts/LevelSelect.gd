class_name LevelSelect
extends Control

@export var weenie_prefab : PackedScene
@onready var weenie_container: HFlowContainer = %"Weenie Container"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var i: int = 0
	for level: PackedScene in GameManager.levels:
		var spawned_obj : LevelWeenie = weenie_prefab.instantiate() as LevelWeenie
		i += 1
		spawned_obj.level_idx = i
		spawned_obj.scene_to_load = level
		weenie_container.add_child(spawned_obj)
