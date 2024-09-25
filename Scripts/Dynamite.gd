class_name Dynamite
extends Area2D


@onready var block_detector: RayCast2D = $"Block Detector"
var click_debounce: bool = false
var start_pos: Vector2

func _ready() -> void:
	start_pos = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var grid_size: float = GameManager.GRID_SIZE
	var held: bool = GameManager.currently_held_object == self
	if held:
		if Input.is_action_just_pressed("drop_block"):
			click_debounce = false
		var mouse_pos : Vector2 = get_global_mouse_position()
		global_position = mouse_pos

		#global_position = round(mouse_pos / grid_size) * grid_size # use this if we want to snape to grid. We currently don't cus it's too easy to click between blocks
		if Input.is_action_just_released("drop_block") and !click_debounce:
			if block_detector.is_colliding():
				var block_collided_with: Placeable = block_detector.get_collider() as Placeable
				if block_collided_with:
					block_collided_with.destroy(global_position)
					GameManager.currently_held_object = null
					queue_free()
					return
			global_position = start_pos
			GameManager.currently_held_object = null


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var m_event: InputEventMouse = event as InputEventMouse
	if !m_event: return
	if !m_event.is_action_released("drop_block"): return
	if GameManager.currently_held_object != null: return
	GameManager.currently_held_object = self
	click_debounce = true
	
