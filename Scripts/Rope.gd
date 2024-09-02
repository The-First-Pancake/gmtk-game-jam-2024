class_name Rope
extends Sprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var block: Placeable = Placeable.currently_held_block
	if is_instance_valid(block):
		global_position = block.global_position #+ Vector2(0,-100)
	else:
		global_position = get_global_mouse_position()
