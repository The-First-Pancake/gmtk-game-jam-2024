class_name LevelWeenie
extends Control

var level_idx : int = 1

@export var scene_to_load: PackedScene
@export var override_text: String = ""
@export var endless: bool = false


@onready var start_sound: AudioStreamPlayer = $StartGameFx

@onready var level_title: Label = $"Level Title"
@onready var completed_flames: Node2D = $CompletedFlames

var unlocked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if level_idx == 1:
		unlocked = true
	else:
		var previous_level: PackedScene = GameManager.levels[level_idx-2]
		if GameManager.current_save.is_level_complete(previous_level):
			unlocked = true
		
	if override_text != "":
		level_title.text = override_text
	else:
		level_title.text = "Level " + str(level_idx)
		
	if (GameManager.current_save.is_level_complete(scene_to_load) or endless):
		unlocked = true
		completed_flames.show()
		
	visible = unlocked
	if (!endless):
		var idol_1: TextureRect = $"HBoxContainer/Idol 1"
		var idol_2: TextureRect = $"HBoxContainer/Idol 2"
		var idol_3: TextureRect = $"HBoxContainer/Idol 3"
		var idols_collected : int = GameManager.current_save.how_many_idols(scene_to_load)
		if (idols_collected >= 1):
			idol_1.show()
		if (idols_collected >= 2):
			idol_1.show()
			idol_2.show()
		if (idols_collected >= 3):
			idol_1.show()
			idol_2.show()
			idol_3.show()

	if (endless):
		var high_score_idol: Label = $"HBoxContainer/High Score Idol"
		var high_score_height: Label = $"HBoxContainer/High Score Height"
		high_score_idol.text = "%02d"%GameManager.current_save.endless_high_idols
		high_score_height.text = "%03d"%GameManager.current_save.endless_high_height

	pass # Replace with function body.



func _on_mouse_entered() -> void:
	modulate.r /= 2
	modulate.g /= 2
	modulate.b /= 2

func _on_mouse_exited() -> void:
	modulate.r *= 2
	modulate.g *= 2
	modulate.b *= 2


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_block"):	
		AudioManager.PlayAudio(start_sound)
		GameManager.load_level_from_packed(scene_to_load)
