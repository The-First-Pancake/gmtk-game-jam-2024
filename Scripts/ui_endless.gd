class_name UI_Endless
extends Node2D

@export var idol_label : Label = null
@export var idol_high_label : Label = null
@export var height_label : Label = null
var base_height : float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	base_height = GameManager.player.global_position.y / 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_height : int = base_height - GameManager.player.global_position.y / 50
	if (player_height > GameManager.current_save.endless_high_height):
		GameManager.current_save.endless_high_height = player_height
	if (GameManager.player.idols_collected > GameManager.current_save.endless_high_idols):
		GameManager.current_save.endless_high_idols = GameManager.player.idols_collected
	if (is_instance_valid(GameManager.player)):
		idol_label.text = "%02d"%GameManager.player.idols_collected
		idol_high_label.text = "%02d"%GameManager.current_save.endless_high_idols
		height_label.text = "%03d"%player_height + "\n" + "%03d"%GameManager.current_save.endless_high_height
