class_name Door
extends Area2D

var top_layer: float = 10
var lower_layer: float = 0
@export var is_exit: bool = false
@onready var door_frame: Sprite2D = $"Door Frame" as Sprite2D
@onready var interior_wall: StaticBody2D = $"Interior Wall"
@onready var interior_wall_2: StaticBody2D = $"Interior Wall2"

func _ready() -> void:
	if is_exit:
		door_frame.z_index = lower_layer
		interior_wall.process_mode = Node.PROCESS_MODE_DISABLED
		interior_wall_2.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		door_frame.z_index = top_layer
		interior_wall.process_mode = Node.PROCESS_MODE_INHERIT
		interior_wall_2.process_mode = Node.PROCESS_MODE_INHERIT

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if is_exit:
			door_frame.z_index = top_layer
			interior_wall.process_mode = Node.PROCESS_MODE_INHERIT
			interior_wall_2.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			door_frame.z_index = lower_layer
			interior_wall.process_mode = Node.PROCESS_MODE_DISABLED
			interior_wall_2.process_mode = Node.PROCESS_MODE_DISABLED

func _on_exit_hitbox_body_exited(body: Node2D) -> void:
	if body is Player:
		GameManager.level_complete()
