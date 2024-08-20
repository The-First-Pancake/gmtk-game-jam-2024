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
		preload("res://Levels/World1/temple_3_holds.tscn"),
		preload("res://Levels/World1/temple_4.tscn"),
		preload("res://Levels/World1/temple_5_overhangs.tscn"),
		preload("res://Levels/World1/temple_6_overhangs_xtreme.tscn"),
		preload("res://Levels/World1/temple_7_oops_all_long.tscn"),
		preload("res://Levels/World1/temple_8_arrows.tscn"),
		preload("res://Levels/World1/temple_9_arrows_on_holds.tscn"),
		preload("res://Levels/World1/temple_10_arrow rain.tscn"),
		preload("res://Levels/World1/temple_11_breaker_intro.tscn"),
		preload("res://Levels/World1/temple_12_breaker_dropper.tscn"),
		preload("res://Levels/World1/temple_13_reverse_breaker.tscn"),
		preload("res://Levels/World1/temple_66_hell.tscn")
	]
	for level in levels:
		var level_dictionary_default : Dictionary = {
			"completed" = false,
			"idols" = 0,
		}
		game_progress_state["level_states"].append(level_dictionary_default)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().current_scene.name == "LevelSelect":
			get_tree().quit()
		else:
			load_level(0)
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
