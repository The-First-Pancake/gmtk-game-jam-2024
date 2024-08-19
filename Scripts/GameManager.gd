extends Node

var player : Player = null
var entrance_door : Door = null
var exit_door : Door = null

var levels : Array[PackedScene]
var current_level : int = 0
var game_progress_state : Dictionary = {"max_level_reached" = 1,
										"level_states" = []}

func _ready() -> void:
	levels = [
		preload("res://Levels/LevelSelect.tscn"),
		preload("res://Levels/World1/temple_1_intro.tscn"),
		preload("res://Levels/World1/temple_2_spikes.tscn"),
		preload("res://Levels/World1/temple_3_holds.tscn")
	]
	for level in levels:
		var level_dictionary_default : Dictionary = {
			"completed" = false,
			"idols" = 0,
		}
		game_progress_state["level_states"].append(level_dictionary_default)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func level_complete() -> void:
	game_progress_state['level_states'][current_level]['completed'] = true
	game_progress_state['level_states'][current_level]['idols'] = player.idols_collected
	load_next_scene()
	
func load_level(idx : int) -> void:
	if (idx >= levels.size()):
		idx = 0 # always go back to level selected if end reached
	current_level = idx;
	get_tree().change_scene_to_packed(levels[idx])

func load_next_scene() -> void:
	current_level += 1
	if (current_level > game_progress_state["max_level_reached"]):
		game_progress_state["max_level_reached"] = current_level
	load_level(current_level)
