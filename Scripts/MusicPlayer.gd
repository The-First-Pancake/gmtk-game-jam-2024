extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var title_music : AudioStreamPlayer = %Music as AudioStreamPlayer
	AudioManager.PlayMusic(title_music)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
