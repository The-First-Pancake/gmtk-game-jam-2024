extends Button

func _on_button_down() -> void:
	GameManager.load_level_from_packed(GameManager.level_select_scene)
