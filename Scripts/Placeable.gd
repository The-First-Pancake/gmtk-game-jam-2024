class_name Placeable
extends CharacterBody2D

enum PlaceState {QUEUED, PLACING, FALLING, PLACED, DESTROYED}
@export var grid_size : float = 50
@export var state : int = PlaceState.PLACED
var hold_point_generator : HoldPointGenerator

const GRID_SIZE: float = 50

signal picked_up
signal placed
signal falling

const DEFAULT_COLLISION_LAYER : int = 1
const UNPLACED_COLLISION_LAYER : int = 2

@onready var impact_sound : AudioStreamPlayer = $BlockImpact01 as AudioStreamPlayer
@onready var shatter_sound : AudioStreamPlayer = $Explosion3003 as AudioStreamPlayer

static var currently_held_block: Placeable = null
var destroy_semaphore : Semaphore = Semaphore.new()

func _ready() -> void:
	if (state == PlaceState.FALLING):
		enter_falling()
	hold_point_generator = $HoldPointGenerator
	destroy_semaphore.post()

func _physics_process(delta: float) -> void:
	if (state == PlaceState.PLACING):
		var mouse_pos : Vector2 = get_global_mouse_position()
		global_position = Vector2(int(mouse_pos.x / grid_size) * grid_size, int(mouse_pos.y / grid_size) * grid_size)
		if (Input.is_action_just_pressed("rotate_block_right")):
			rotation += deg_to_rad(90)
			return
		if (Input.is_action_just_pressed("rotate_block_left")):
			rotation -= deg_to_rad(90)
			return
		if (!check_for_collisions() and Input.is_action_just_pressed("drop_block")):
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
	if (state == PlaceState.QUEUED):
		if Input.is_action_just_pressed("drop_block"):
			if currently_held_block == null:
				enter_placing()

func enter_queued() -> void:
	state = PlaceState.QUEUED
	set_collision_layer_value(DEFAULT_COLLISION_LAYER, false);
	set_collision_layer_value(UNPLACED_COLLISION_LAYER, true);
	# Deal with child nodes
	for child in get_children():
		if (child is Area2D):
			var area_2d_child : Area2D = child as Area2D
			area_2d_child.set_collision_layer_value(DEFAULT_COLLISION_LAYER, false);
			area_2d_child.set_collision_layer_value(UNPLACED_COLLISION_LAYER, true);

func enter_placing() -> void:
	currently_held_block = self
	await get_tree().process_frame
	picked_up.emit()
	modulate.a = 0.5 # make transparent
	state = PlaceState.PLACING 

func enter_falling() -> void:
	currently_held_block = null
	set_collision_layer_value(DEFAULT_COLLISION_LAYER, true);
	set_collision_layer_value(UNPLACED_COLLISION_LAYER, false);
	# Deal with child nodes
	for child in get_children():
		if (child is Area2D):
			var area_2d_child : Area2D = child as Area2D
			area_2d_child.set_collision_layer_value(DEFAULT_COLLISION_LAYER, true);
			area_2d_child.set_collision_layer_value(UNPLACED_COLLISION_LAYER, false);
	modulate.a = 1 # make solid
	state = PlaceState.FALLING
	falling.emit()

func enter_placed() -> void:
	state = PlaceState.PLACED
	global_position = round(global_position / grid_size) * grid_size #Snap to the nearest grid space
	CameraController.instance.apply_shake()
	impact_sound.play()
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
	
func destroy(collision_point_global : Vector2) -> void:
	if destroy_semaphore.try_wait():
		if (state != PlaceState.DESTROYED):
			state = PlaceState.DESTROYED
			AudioManager.PlayAudio(shatter_sound)
			for child in get_children():
				if child is Sprite2D:
					continue
				if child is CollisionPolygon2D:
					continue
				else: 
					child.queue_free()
			enter_placed()
			$Sprite2D/ShardEmitter.shatter(collision_point_global)
