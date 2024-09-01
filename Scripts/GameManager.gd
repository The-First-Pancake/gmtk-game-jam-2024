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
const SAVE_PATH: String = "user://save.tres"
var current_save: GameSave = null

func _ready() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH) as GameSave
		print(current_save.endless_high_height)
	else:
		setup_new_save()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip_level"):
		level_complete()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
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

func setup_new_save() -> void:
	print("Resetting Save")
	current_save = load("res://Levels/Game Saves/Starting_Save.tres").duplicate()
	save_game()

func save_game() -> void:
	ResourceSaver.save(current_save, SAVE_PATH)

func complete_all_levels() -> void:
	for level: PackedScene in levels:
		current_save.complete_level(level,0)
