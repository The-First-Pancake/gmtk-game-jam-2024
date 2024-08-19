extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func PlayAudio(audio: AudioStreamPlayer) -> void:
	var audio_dupe: AudioStreamPlayer = audio
	audio_dupe.play()
