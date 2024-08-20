extends Node2D

@onready var black_cover: ColorRect = $"Black cover"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	black_cover.modulate = Color.WHITE
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(black_cover, "modulate", Color.TRANSPARENT, 1)
	await tween.finished
	await get_tree().create_timer(15).timeout
	print("ya")
	tween = get_tree().create_tween()
	tween.tween_property(black_cover, "modulate", Color.WHITE, 1)
	await  tween.finished
	GameManager.load_level_from_packed(GameManager.level_select_scene)
