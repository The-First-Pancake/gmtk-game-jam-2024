class_name UI
extends Node2D

@export var idol_label : Label = null
@export var height_label : Label = null
var base_height : int = 0

func _ready() -> void:
	await get_tree().process_frame
	base_height = GameManager.player.global_position.y / 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (is_instance_valid(GameManager.player)):
		idol_label.text = str(GameManager.player.idols_collected) + "/3"
		var player_height : int = ceil(base_height - GameManager.player.global_position.y / 50)
		var door_height : int = floor(base_height - GameManager.exit_door.global_position.y / 50)
		height_label.text = "%02d"%player_height + "\n" + "%02d"%door_height
