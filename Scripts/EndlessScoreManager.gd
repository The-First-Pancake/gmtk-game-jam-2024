class_name EndlessScoreManager
extends Node2D

@export var idol_label : Label = null
@export var idol_high_label : Label = null
@export var height_label : Label = null
var base_height : float = 0.0

var max_height_this_run: int = 0

func _ready() -> void:
	await get_tree().process_frame
	base_height = GameManager.player.global_position.y / 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player: Player = GameManager.player
	var player_height : int = base_height - int(player.global_position.y / 50)
	max_height_this_run = max(max_height_this_run, player_height)
	GameManager.endless_run_height = max_height_this_run
	GameManager.endless_run_idols = player.idols_collected
	if (is_instance_valid(player)):
		idol_label.text = "%02d"%player.idols_collected
		idol_high_label.text = "%02d"%GameManager.current_save.endless_high_idols
		height_label.text = "%03d"%player_height + "\n" + "%03d"%GameManager.current_save.endless_high_height
