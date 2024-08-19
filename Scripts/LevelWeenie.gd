class_name LevelWeenie
extends Area2D

var level_idx : int = 1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (GameManager.game_progress_state['max_level_reached'] >= level_idx):
		show()
	$IdolUI.text = "Level " + str(level_idx)
	if (GameManager.game_progress_state['level_states'][level_idx]['completed']):
		$CompletedFlames.show()
	var idols_collected : int = GameManager.game_progress_state['level_states'][level_idx]['idols']
	if (idols_collected >= 1):
		$"Idol 1".show()
	if (idols_collected >= 2):
		$"Idol 1".show()
		$"Idol 2".show()
	if (idols_collected >= 3):
		$"Idol 1".show()
		$"Idol 2".show()
		$"Idol 3".show()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("drop_block"):
			GameManager.load_level(level_idx)

func _on_mouse_entered() -> void:
	modulate.r /= 2
	modulate.g /= 2
	modulate.b /= 2

func _on_mouse_exited() -> void:
	modulate.r *= 2
	modulate.g *= 2
	modulate.b *= 2
