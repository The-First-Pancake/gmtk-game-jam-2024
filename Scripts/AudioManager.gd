extends Node


func PlayAudio(audio: AudioStreamPlayer, vibrate_controller_idx: int = 0) -> AudioStreamPlayer:
	var audio_dupe: AudioStreamPlayer = audio.duplicate()
	add_child(audio_dupe)
	audio_dupe.play()
	audio_dupe.finished.connect(func() -> void:
		audio_dupe.queue_free()
	)
	audio_dupe.tree_exited.connect(func() -> void:
		Input.stop_joy_vibration(vibrate_controller_idx)
	)
	if vibrate_controller_idx >= 0:
		Input.start_joy_vibration(vibrate_controller_idx, 0.5, 0, 0)
	return audio_dupe

var current_music: AudioStreamPlayer = null

func PlayMusic(audio: AudioStreamPlayer) -> void:
	if current_music:
		if current_music.stream == audio.stream: return
		current_music.stop()
	var audio_dupe: AudioStreamPlayer = audio.duplicate()
	add_child(audio_dupe)
	audio_dupe.play()
	current_music = audio_dupe
	audio_dupe.finished.connect(func() -> void:
		audio_dupe.queue_free()
	)
