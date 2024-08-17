extends CharacterBody2D

enum PlaceState {PLACING, FALLING, PLACED}
var state : int = PlaceState.PLACING
var collider : CollisionPolygon2D = null

func _ready() -> void:
	enter_placing()
	collider = get_node_or_null("CollisionPolygon2D")
	

func _physics_process(delta: float) -> void:
	if (state == PlaceState.PLACING):
		var mouse_pos : Vector2 = get_global_mouse_position()
		position = mouse_pos
		var collision : KinematicCollision2D = move_and_collide(Vector2.ZERO, true);
		if (Input.is_action_just_pressed("rotate_block")):
			rotation += deg_to_rad(90)
			return
		if (Input.is_action_just_pressed("drop_block")):
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
