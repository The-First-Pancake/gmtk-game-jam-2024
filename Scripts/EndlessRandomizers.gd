extends Node2D
@onready var block_spawner: BlockSpawner = $BlockSpawner
@export var block_prefabs : Array[PackedScene]
@export var dangers : Array[SpawnObject]
@export var y_level_switch : int = 5
var last_threshold : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	regenerate_block_spawner()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player_position : int = -(GameManager.player.global_position.y / 50)
	if (player_position > last_threshold + y_level_switch):
		last_threshold = player_position
		regenerate_block_spawner()

func regenerate_block_spawner() -> void:
	randomize()
	block_spawner.clear_added_spawns()
	var num_new_positions : int = randi_range(1, dangers.size())
	for i in num_new_positions:
		var new_danger : SpawnObject = dangers.pick_random().duplicate()
		new_danger.spawn_count += last_threshold / y_level_switch
		new_danger.spawn_count /= num_new_positions
		block_spawner.add_spawn_object(new_danger)
	block_prefabs.shuffle()
	var lower_block_idx : int = randi_range(0, block_prefabs.size())
	var upper_block_idx : int = randi_range(0, block_prefabs.size())
	if (upper_block_idx > lower_block_idx):
		block_spawner.block_prefabs = block_prefabs.slice(lower_block_idx, upper_block_idx)
	if (lower_block_idx > upper_block_idx):
		block_spawner.block_prefabs = block_prefabs.slice(upper_block_idx, lower_block_idx)
	else:
		block_spawner.block_prefabs = [block_prefabs[lower_block_idx % block_prefabs.size()]]
		
