extends Node

var player : Player = null
var entrance_door : Door = null
var exit_door : Door = null

@onready var levels : Array[PackedScene] = [
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
	]

var current_level : PackedScene = null
var game_progress_state : Dictionary = {"max_level_reached" = 1,
										"level_states" = []}

var level_select_scene: PackedScene = preload("uid://dkkns7jwrd842")
const SAVE_PATH: String = "user://save.tres"
var current_save: GameSave = null

func _ready() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH) as GameSave
		print(current_save.endless_high_score)
	else:
		setup_new_save()
	
	for level in levels:
		var level_dictionary_default : Dictionary = {
			"completed" = false,
			"idols" = 0,
		}
		game_progress_state["level_states"].append(level_dictionary_default)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip_level"):
		level_complete()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().current_scene.name == "LevelSelect":
			get_tree().quit()
		else:
			load_level_from_packed(level_select_scene)
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func level_complete() -> void:
	current_save.complete_level(current_level, player.idols_collected) 
	save_game()
	load_level_from_packed(level_select_scene)

func load_level_from_packed(scene: PackedScene) -> void:
	current_level = scene
	get_tree().change_scene_to_packed(scene)

func setup_new_save() -> void:
	print("Resetting Save")
	current_save = load("uid://c6sx65edmv72k")
	save_game()

func save_game() -> void:
	ResourceSaver.save(current_save, SAVE_PATH)
