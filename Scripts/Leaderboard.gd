class_name Leaderboard
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var high_score_idol: Label = %"High Score Idol"
	high_score_idol.text = str(GameManager.endless_run_idols)
	var high_score_height: Label = %"High Score Height"
	high_score_height.text = "%03d"%GameManager.endless_run_height
	await get_tree().process_frame
	refresh_board()
@onready var loading_label: Label = %"Loading Label"

var currently_refreshing: bool = false
signal board_refreshed
func refresh_board() -> void:
	if currently_refreshing:
		await board_refreshed
	currently_refreshing = true
	var leaderboard_entry_prefab: PackedScene = preload("res://Prefabs/leaderboard_entry.tscn")
	var leaderboard_container: VBoxContainer = %"Leaderboard Container"
	loading_label.visible = true
	for child: Node in leaderboard_container.get_children():
		if child.name == "Header":
			continue
		if child == loading_label:
			continue
		child.queue_free()
	print("abe")
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(10).sw_get_scores_complete
	print("tabe")
	
	print(sw_result)
	var i: int = 0
	for score_entry: Dictionary in sw_result.scores:
		i += 1
		var new_entry: LeaderboardEntry = leaderboard_entry_prefab.instantiate()
		new_entry.setup(i,score_entry.player_name,score_entry.score)
		leaderboard_container.add_child(new_entry)
	loading_label.visible = false
	board_refreshed.emit()
	currently_refreshing = false


func save_score() -> void:
	var name_entry: TextEdit = %"Name Entry"
	var score_submit_button: Button = %"Score Submit Button"
	score_submit_button.disabled = true

	await SilentWolf.Scores.save_score(name_entry.text, GameManager.endless_run_height).sw_save_score_complete
	refresh_board()

func continue_button() -> void:
	GameManager.load_level_from_packed(GameManager.level_select_scene)
