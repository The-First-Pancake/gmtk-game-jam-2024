extends CharacterBody2D

enum PlaceState {PLACING, FALLING, PLACED}
@export var grid_size : float = 50
var state : int = PlaceState.PLACING

func _ready() -> void:
	enter_placing()

func _physics_process(delta: float) -> void:
	if (state == PlaceState.PLACING):
		var mouse_pos : Vector2 = get_global_mouse_position()
		position = Vector2(int(mouse_pos.x / grid_size) * grid_size, int(mouse_pos.y / grid_size) * grid_size)
		if (Input.is_action_just_pressed("rotate_block")):
			rotation += deg_to_rad(90)
			return
		if (!check_for_collisions() and Input.is_action_just_pressed("drop_block")):
			enter_falling()
	elif (state == PlaceState.FALLING):
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
			move_and_slide()
		else:
			enter_placed()
	elif (state == PlaceState.PLACED):
		return # do not update object when placed

func enter_placing() -> void:
	modulate.a = 0.5 # make transparent
	state = PlaceState.PLACING

func enter_falling() -> void:
	modulate.a = 1 # make solid
	state = PlaceState.FALLING

func enter_placed() -> void:
	state = PlaceState.PLACED
	
func check_for_collisions() -> bool:
	var collision : KinematicCollision2D = move_and_collide(Vector2.ZERO, true, 0);
	if (collision):
		modulate.g = 0.5
		modulate.r = 2 # Redden unplaceable blocks
		modulate.b = 0.5
	else:
		modulate.g = 1
		modulate.r = 1
		modulate.b = 1
	return is_instance_valid(collision)
