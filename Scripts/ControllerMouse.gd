extends Node2D

var mouse_pos : Vector2 = Vector2()
var mouse_speed : float = 10

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _process(delta: float) -> void:
	var mouse_rel : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("controller_mouse_up"):
		mouse_rel += Vector2.UP * mouse_speed
	elif Input.is_action_pressed("controller_mouse_down"):
		mouse_rel += Vector2.DOWN * mouse_speed
	elif Input.is_action_pressed("controller_mouse_left"):
		mouse_rel += Vector2.LEFT * mouse_speed
	elif Input.is_action_pressed("controller_mouse_right"):
		mouse_rel += Vector2.RIGHT * mouse_speed
	if (Input.is_action_just_pressed("drop_block")):
		fake_press()
	if mouse_rel != Vector2.ZERO:
		Input.warp_mouse(mouse_pos + mouse_rel)
	global_position = get_global_mouse_position()

func fake_press() -> void:
	var a : InputEventMouseButton = InputEventMouseButton.new()
	a.position = get_viewport().get_mouse_position()
	a.button_index = MOUSE_BUTTON_LEFT
	a.pressed = true
	Input.parse_input_event(a)
	await get_tree().process_frame
	a.pressed = false
	Input.parse_input_event(a)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = event.position
