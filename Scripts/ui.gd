class_name UI
extends Node2D

@export var idol_label : Label = null
@export var height_label : Label = null
var base_height : int = 0

var player_height : int:
	get:
		return round((GameManager.player.global_position.y + 50) / 50)

var exit_door_height: int:
	get:
		return round((GameManager.exit_door.global_position.y) / 50)

func _ready() -> void:
	await get_tree().process_frame
	base_height = max(player_height, exit_door_height)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (is_instance_valid(GameManager.player)):
		idol_label.text = str(GameManager.player.idols_collected) + "/3"
		var relative_player_height : int = base_height - player_height
		var relative_exit_height: int = base_height - exit_door_height
		height_label.text = "%02d"%relative_player_height + "\n" + "%02d"%relative_exit_height
