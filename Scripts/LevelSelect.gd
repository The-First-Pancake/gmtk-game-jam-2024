class_name LevelSelect
extends Node2D

@export var weenie_prefab : PackedScene

const weenie_size_x : int = 300
const weenie_size_y : int = 350

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in GameManager.levels.size():
		if (i != 0):
			var spawned_obj : LevelWeenie = weenie_prefab.instantiate() as LevelWeenie
			spawned_obj.level_idx = i
			add_child(spawned_obj)
			var x_pos : int = weenie_size_x * (i) % 1080
			var y_pos : int = (int(weenie_size_x * (i) / 1080)) * weenie_size_y + 150
			spawned_obj.global_position = Vector2(x_pos, y_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
