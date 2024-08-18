class_name Placeable
extends CharacterBody2D

enum PlaceState {QUEUED, PLACING, FALLING, PLACED}
@export var grid_size : float = 50
var state : int = PlaceState.QUEUED
var hold_point_generator : HoldPointGenerator

signal picked_up
signal placed

const DEFAULT_COLLISION_LAYER : int = 1
const UNPLACED_COLLISION_LAYER : int = 2

func _ready() -> void:
	hold_point_generator = $HoldPointGenerator
	enter_queued()

func _physics_process(delta: float) -> void:
	if (state == PlaceState.PLACING):
		var mouse_pos : Vector2 = get_global_mouse_position()
		global_position = Vector2(int(mouse_pos.x / grid_size) * grid_size, int(mouse_pos.y / grid_size) * grid_size)
		if (Input.is_action_just_pressed("rotate_block")):
			rotation += deg_to_rad(90)
			return
		if (!check_for_collisions() and Input.is_action_just_released("drop_block")):
			enter_falling()
	elif (state == PlaceState.FALLING):
		# Add the gravity.
		velocity += get_gravity() * delta
		var collision : KinematicCollision2D = move_and_collide(velocity * delta)
		if (collision):
			if (collision.get_collider() is Player):
				if (collision.get_angle(up_direction) < deg_to_rad(45) and collision.get_angle(up_direction) > deg_to_rad(-45)):
					var player : Player = collision.get_collider() as Player
					player.try_squash()
			elif (collision.get_angle(up_direction) < deg_to_rad(45) and collision.get_angle(up_direction) > deg_to_rad(-45)):
				enter_placed()

func on_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (state == PlaceState.QUEUED):
			if (Input.is_action_just_pressed("drop_block")):
				enter_placing()

func enter_queued() -> void:
	state = PlaceState.QUEUED

func enter_placing() -> void:
	picked_up.emit()
	set_collision_layer_value(DEFAULT_COLLISION_LAYER, false);
	set_collision_layer_value(UNPLACED_COLLISION_LAYER, true);
	modulate.a = 0.5 # make transparent
	state = PlaceState.PLACING

func enter_falling() -> void:
	set_collision_layer_value(DEFAULT_COLLISION_LAYER, true);
	set_collision_layer_value(UNPLACED_COLLISION_LAYER, false);
	modulate.a = 1 # make solid
	state = PlaceState.FALLING

func enter_placed() -> void:
	state = PlaceState.PLACED
	placed.emit()
	
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
