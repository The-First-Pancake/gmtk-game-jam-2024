class_name Rope
extends Sprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var object: Node2D = GameManager.currently_held_object
	if is_instance_valid(object):
		global_position = object.global_position #+ Vector2(0,-100)
	else:
		global_position = get_global_mouse_position()
