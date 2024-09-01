extends VBoxContainer

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_block"):
		GameManager.complete_all_levels()
		get_tree().reload_current_scene()

func _on_mouse_entered() -> void:
	modulate.r /= 2
	modulate.g /= 2
	modulate.b /= 2

func _on_mouse_exited() -> void:
	modulate.r *= 2
	modulate.g *= 2
	modulate.b *= 2
