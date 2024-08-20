extends Button

@onready var start_sound: AudioStreamPlayer = $"Button Press Sound"

func _on_button_down() -> void:
	AudioManager.PlayAudio(start_sound)
	GameManager.load_level_from_packed(GameManager.level_select_scene)
