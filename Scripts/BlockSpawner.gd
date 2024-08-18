class_name BlockSpawner
extends Marker2D

var spawn_timer : Timer

@export var block_prefabs : Array[PackedScene]
@export var spawn_objects: Array[Resource]
@export var spawn_object_probability : float = 0.0

var spawned_block : Placeable
var spawned_object_counts : Array[int] = []
var total_objects_to_spawn : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = $SpawnTimer as Timer
	spawned_object_counts.resize(len(spawn_objects))
	refresh_spawn_object_counts()
	generate_and_spawn_block()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_and_spawn_block() -> void:
	spawned_block = block_prefabs.pick_random().instantiate() as Placeable
	add_child(spawned_block)
	spawned_block.global_position = global_position
	spawned_block.connect("picked_up", _spawned_block_picked_up)
	generate_and_spawn_hold_objects(spawned_block)

func generate_and_spawn_hold_objects(block: Placeable) -> void:
	for spawn_point_idx in len(block.hold_point_generator.get_generated_points()):
		if (randf() > spawn_object_probability):
			var cum_probability : float = 0
			var object_choice : float = randf()
			for i in len(spawn_objects):
				print("Total objects to spawn @ for loop: ", total_objects_to_spawn)
				cum_probability += spawned_object_counts[i] / total_objects_to_spawn
				if (object_choice < cum_probability):
					spawned_object_counts[i] -= 1
					total_objects_to_spawn -= 1
					spawn_object_on_hold(spawn_objects[i], block, spawn_point_idx)
					if (total_objects_to_spawn == 0):
						print("remaking spawned objects")
						refresh_spawn_object_counts()
					break

func spawn_object_on_hold(object: SpawnObject, block: Placeable, spawn_point_idx: int) -> void:
	var spawned_obj : Node2D = object.spawn_prefab.instantiate() as Node2D
	block.add_child(spawned_obj)
	spawned_obj.position = block.hold_point_generator.generated_points[spawn_point_idx]
	var orth_vector : Vector2 = block.hold_point_generator.generated_orth_vectors[spawn_point_idx]
	spawned_obj.rotate(Vector2.UP.angle_to(orth_vector))

func refresh_spawn_object_counts() -> void:
	total_objects_to_spawn = 0
	for i in len(spawn_objects):
		spawned_object_counts[i] = spawn_objects[i].spawn_count
		total_objects_to_spawn += spawn_objects[i].spawn_count

func _spawned_block_picked_up() -> void:
	spawn_timer.start()
	spawned_block.disconnect("picked_up", _spawned_block_picked_up)

func _spawn_timer_finished() -> void:
	generate_and_spawn_block()
