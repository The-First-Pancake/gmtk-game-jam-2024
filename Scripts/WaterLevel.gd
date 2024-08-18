extends Node2D

@export var rise_speed: float = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y -= rise_speed * delta
