class_name UI
extends Node2D

@export var idol_label : Label = null
@export var height_label : Label = null
var base_height : float = 0.0

func _ready() -> void:
	base_height = GameManager.player.global_position.y / 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	idol_label.text = str(GameManager.player.idols_collected) + "/3"
	height_label.text = str(int(base_height - GameManager.player.global_position.y / 50)) + "m\n600m"
