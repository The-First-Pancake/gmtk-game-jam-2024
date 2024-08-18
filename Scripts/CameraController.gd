class_name CameraController
extends Camera2D

var instance: CameraController
@export var target: Node2D
@export var step: float
@export var top_trigger: float
@export var bottom_trigger: float


func _ready() -> void:
	instance = self

var is_sliding: bool = false

func _process(delta: float) -> void:
	if is_sliding: return
	var screen_top: float = global_position.y - get_viewport_rect().size.y/2
	var screen_bottom: float = global_position.y + get_viewport_rect().size.y/2
	
	var slide_tween: Tween = get_tree().create_tween()
	slide_tween.set_trans(Tween.TRANS_QUAD)
	
	if (is_instance_valid(target)):
		if target.global_position.y < screen_top + top_trigger:
			slide_tween.tween_property(self, "global_position", global_position - Vector2(0,step),.3)
			is_sliding = true
			await slide_tween.finished
			is_sliding = false
		if target.global_position.y > screen_bottom - bottom_trigger:
			slide_tween.tween_property(self, "global_position", global_position + Vector2(0,step),.3)
			is_sliding = true
			await slide_tween.finished
			is_sliding = false
