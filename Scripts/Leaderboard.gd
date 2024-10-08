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
	loading_label.visible = true
	loading_label.text = "Loading Scores..."
	var leaderboard_container: VBoxContainer = %"Leaderboard Container"
	for child: Node in leaderboard_container.get_children():
		if child.name == "Header":
			continue
		if child == loading_label:
			continue
		child.queue_free()
	#TODO failsafe for if we don't connect
	
	get_tree().create_timer(3).timeout.connect(refresh_failed)
	SilentWolf.Scores.get_scores(10).sw_get_scores_complete.connect(refresh_success)

func refresh_failed() -> void:
	if currently_refreshing == false:
		return
	loading_label.text = "Couldn't Connect to Leaderboard"
	currently_refreshing = false

func refresh_success(sw_result: Dictionary) -> void:
	if currently_refreshing == false:
		return
	var leaderboard_entry_prefab: PackedScene = preload("res://Prefabs/leaderboard_entry.tscn")
	var leaderboard_container: VBoxContainer = %"Leaderboard Container"
	var i: int = 0
	for score_entry: Dictionary in sw_result.scores:
		i += 1
		var new_entry: LeaderboardEntry = leaderboard_entry_prefab.instantiate()
		new_entry.setup(i,score_entry.player_name,score_entry.score)
		leaderboard_container.add_child(new_entry)
	loading_label.visible = false
	board_refreshed.emit()
	currently_refreshing = false

var score_submitted: bool = false

@onready var score_submit_button: Button = %"Score Submit Button"
@onready var name_entry: TextEdit = %"Name Entry"
func _process(delta: float) -> void:
	score_submit_button.disabled = score_submitted or name_entry.text == ""

func save_score() -> void:
	score_submitted = true
	await SilentWolf.Scores.save_score(name_entry.text, GameManager.endless_run_height).sw_save_score_complete
	refresh_board()
