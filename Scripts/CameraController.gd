class_name CameraController
extends Camera2D

static var instance: CameraController
@export var step: float
@export var top_trigger: float
@export var bottom_trigger: float
@export var random_stength: float = 15.0
@export var shake_fade: float = 5.0

var RNG : RandomNumberGenerator = RandomNumberGenerator.new()

var shake_strength : float = 0.0

func _ready() -> void:
	instance = self

var is_sliding: bool = false

func apply_shake() -> void:
	shake_strength = random_stength
	
func random_offset() -> Vector2:
	return Vector2(RNG.randf_range(-shake_strength, shake_strength), RNG.randf_range(-shake_strength, shake_strength))

func _process(delta: float) -> void:
	if is_sliding: return
	var screen_top: float = global_position.y - get_viewport_rect().size.y/2
	var screen_bottom: float = global_position.y + get_viewport_rect().size.y/2
	
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade * delta)
		
	offset = random_offset()
	
	if !GameManager.player: return
	if GameManager.player.dying: return
	if GameManager.player.global_position.y < screen_top + top_trigger:
		var slide_tween: Tween = get_tree().create_tween()
		slide_tween.set_trans(Tween.TRANS_QUAD)
		slide_tween.tween_property(self, "global_position", global_position - Vector2(0,step),.3)
		is_sliding = true
		await slide_tween.finished
		is_sliding = false
	if GameManager.player.global_position.y > screen_bottom - bottom_trigger:
		var slide_tween: Tween = get_tree().create_tween()
		slide_tween.set_trans(Tween.TRANS_QUAD)
		slide_tween.tween_property(self, "global_position", global_position + Vector2(0,step),.3)
		is_sliding = true
		await slide_tween.finished
		is_sliding = false
	
