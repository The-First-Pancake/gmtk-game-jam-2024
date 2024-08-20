extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func PlayAudio(audio: AudioStreamPlayer) -> void:
	var audio_dupe: AudioStreamPlayer = audio.duplicate()
	add_child(audio_dupe)
	audio_dupe.play()
	audio_dupe.finished.connect(func() -> void:
		audio_dupe.queue_free()
	)

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
