class_name SpawnObject
extends Resource

@export var spawn_prefab : PackedScene
@export var spawn_count : int

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_spawn_prefab : PackedScene = null, p_spawn_count : int = 0) -> void:
	spawn_prefab = p_spawn_prefab
	spawn_count = p_spawn_count
