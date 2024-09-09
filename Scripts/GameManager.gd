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
var level_select_scene: PackedScene = preload("res://Levels/LevelSelect.tscn")
var splash_screen_scene: PackedScene = preload("res://Levels/SplashScreen.tscn")
var leaderboard_scene: PackedScene = preload("res://Levels/Leaderboard.tscn")
const SAVE_PATH: String = "user://save.tres"
var current_save: GameSave = null

signal loaded_new_scene

func _ready() -> void:
	var silentwolf_api_file: FileAccess = FileAccess.open("res://Keys/SilentwolfAPI.txt", FileAccess.READ)
	if !silentwolf_api_file:
		push_error("No API key for silentwolf found. Add folder to resources called 'Keys' and put SilentwolfAPI.txt into it")
		#get_tree().quit()
	var silentwolf_api_key: String = silentwolf_api_file.get_as_text().split("\n")[0]
	SilentWolf.configure({
		"api_key": silentwolf_api_key,
		"game_id": "Cappy&Tappy",
		"log_level": 1 #what level of info do we want printed about connectivity
	})

	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH) as GameSave
		if current_save == null: # if old save type, we have to reset
			setup_new_save()
	else:
		setup_new_save()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("skip_level"):
		if get_tree().current_scene is not Control: #don't allow restart in menus
			level_complete()
	if Input.is_action_just_pressed("restart"): 
		if get_tree().current_scene is not Control: #don't allow restart in menus
			get_tree().reload_current_scene()
			emit_signal("loaded_new_scene")
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().current_scene.name == "LevelSelect":
			load_level_from_packed(splash_screen_scene)
		elif get_tree().current_scene.name == "SplashScreen":
			if OS.get_name() != "Web":
				get_tree().quit()
		else:
			load_level_from_packed(level_select_scene)
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			
var victory_screen_scene: PackedScene = preload("res://Levels/victory_screen.tscn")

func level_complete() -> void:
	current_save.complete_level(current_level, player.idols_collected)
	save_game()
	if current_level == levels.back():
		load_level_from_packed(victory_screen_scene)
	else:
		load_level_from_packed(level_select_scene)
	
func load_level_from_packed(scene: PackedScene) -> void:
	current_level = scene
	get_tree().change_scene_to_packed(scene)
	emit_signal("loaded_new_scene")

func setup_new_save() -> void:
	print("Resetting Save")
	current_save = load("res://Levels/Game Saves/Starting_Save.tres").duplicate()
	save_game()

func save_game() -> void:
	ResourceSaver.save(current_save, SAVE_PATH)

func complete_all_levels() -> void:
	for level: PackedScene in levels:
		current_save.complete_level(level,0)
	save_game()


var endless_run_height: int = 0:
	set(new_val):
		endless_run_height = new_val
		current_save.endless_high_height = max(new_val, current_save.endless_high_height)
var endless_run_idols: int = 0:
	set(new_val):
		endless_run_idols = new_val
		current_save.endless_high_idols = max(new_val, current_save.endless_high_idols)

func player_die() -> void:
	if get_tree().current_scene.name == "Endless Level":
		save_game()
		load_level_from_packed(leaderboard_scene)
	else:
		get_tree().reload_current_scene()
		emit_signal("loaded_new_scene")
