extends Node


func PlayAudio(audio: AudioStreamPlayer) -> AudioStreamPlayer:
	var audio_dupe: AudioStreamPlayer = audio.duplicate()
	add_child(audio_dupe)
	audio_dupe.play()

	var audio_haptics_dupe: AudioStreamPlayer = audio.duplicate()
	add_child(audio_haptics_dupe)
	audio_haptics_dupe.bus = "AudioHaptics"
	audio_haptics_dupe.volume_db = 20
	audio_haptics_dupe.play()
	
	audio_dupe.finished.connect(func() -> void:
		audio_dupe.queue_free()
	)
	
	audio_dupe.tree_exited.connect(func() -> void:
		audio_haptics_dupe.queue_free()
	)
	
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
