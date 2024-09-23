class_name Placeable
extends CharacterBody2D

enum PlaceState {QUEUED, PLACING, FALLING, HARPOONED, PLACED, DESTROYED}
@export var state : int = PlaceState.PLACED
var hold_point_generator : HoldPointGenerator


signal picked_up
signal placed
signal falling
signal destroyed

const DEFAULT_COLLISION_LAYER : int = 1
const UNPLACED_COLLISION_LAYER : int = 2

@onready var impact_sound : AudioStreamPlayer = $BlockImpact01 as AudioStreamPlayer
@onready var shatter_sound : AudioStreamPlayer = $Explosion3003 as AudioStreamPlayer

var destroy_semaphore : Semaphore = Semaphore.new()
var targeted_by_harpoon: bool = false
var harpooned_accel: float = 3500
var harpooned_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
	if (state == PlaceState.FALLING):
		enter_falling()
	hold_point_generator = $HoldPointGenerator
	destroy_semaphore.post()

func get_closest_cell_center(to_point: Vector2) -> Vector2:
	var center_points: PackedVector2Array = hold_point_generator.generated_cell_center_points
	var closest_point: Vector2 = Vector2(100000,100000)
	for cell_center: Vector2 in center_points:
		if to_global(cell_center).distance_to(to_point) < closest_point.distance_to(to_point):
			closest_point = to_global(cell_center)
	return closest_point

func _physics_process(delta: float) -> void:
	if (state == PlaceState.PLACING):
		var grid_size: float = GameManager.GRID_SIZE
		var mouse_pos : Vector2 = get_global_mouse_position()
		global_position = round(mouse_pos / grid_size) * grid_size
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
	elif state == PlaceState.HARPOONED:
		velocity += harpooned_accel * harpooned_dir * delta
		var collision : KinematicCollision2D = move_and_collide(velocity * delta)
		if (collision):
			if (collision.get_collider() is Player):
				collision.get_collider().velocity = velocity
				#if (collision.get_angle(-harpooned_dir) < deg_to_rad(45) and collision.get_angle(-harpooned_dir) > deg_to_rad(-45)):
					#var player : Player = collision.get_collider() as Player
					#player.try_squash()
			elif (collision.get_angle(-harpooned_dir) < deg_to_rad(45) and collision.get_angle(-harpooned_dir) > deg_to_rad(-45)):
				enter_placed()
	if (state == PlaceState.QUEUED):
		if Input.is_action_just_pressed("drop_block"): #Pick Up
			if GameManager.currently_held_object == null:
				enter_placing()

func align_to_grid() -> void:
	var grid_size: float = GameManager.GRID_SIZE
	global_position = round(global_position / grid_size) * grid_size #Snap to the nearest grid space

func enter_harpooned(delay: float,dir: Vector2) -> void:
	await get_tree().create_timer(delay).timeout
	align_to_grid()
	velocity = Vector2.ZERO
	harpooned_dir = dir
	state = PlaceState.HARPOONED

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
	GameManager.currently_held_object = self
	await get_tree().process_frame
	picked_up.emit()
	modulate.a = 0.5 # make transparent
	state = PlaceState.PLACING 

func enter_falling() -> void:
	GameManager.currently_held_object = null
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
	velocity = Vector2.ZERO
	state = PlaceState.PLACED
	align_to_grid()
	CameraController.instance.apply_shake()
	AudioManager.PlayAudio(impact_sound)
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
			destroyed.emit()
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
