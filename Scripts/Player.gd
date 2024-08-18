class_name Player
extends CharacterBody2D


var jump_velocity: float = -850.0
var acceleration: float = 3000
var deceleration: float = 4000
var max_speed: float = 700

var leap_velocity: float = 1350.0

var downslide_speed: float = 300
var current_hold: Node2D = null

var coyote_time: float = 0.1

var terminal_velocity: float = 1500

var was_on_floor: bool = true

var campfires: Array[Campfire] = []

@onready var side_hand_point: Marker2D = %"Side Hand Point" as Marker2D
@onready var top_hand_point: Marker2D = %"Top Hand Point" as Marker2D

@onready var gravity_reduce_timer: Timer = %"Gravity Reduce Timer" as Timer

func _process(delta: float) -> void:
	if current_hold == null:
		# Add the gravity.
		apply_gravity(delta)
		
		#grab holds
		if Input.is_action_just_pressed("jump"):
			var mid_air_hold_detector: Area2D = %"Mid-Air Hold Detector" as Area2D
			var grounded_hold_detector_2: Area2D = %"Grounded Hold Detector2" as Area2D
			
			var holds: Array[Area2D] = []
			if is_on_floor():
				holds = grounded_hold_detector_2.get_overlapping_areas()
			else:
				holds = mid_air_hold_detector.get_overlapping_areas()
			
			#Grab the closest hold
			var closest_hold: Node2D = null
			for hold in holds:
				if !hold.is_in_group("hold"): continue
				if abs(hold.rotation_degrees) < 1: continue #if the hold is upright we can't grab it
				if closest_hold == null:
					closest_hold = hold
					continue
				if side_hand_point.global_position.distance_to(hold.global_position) < side_hand_point.global_position.distance_to(closest_hold.global_position):
					closest_hold = hold
			if closest_hold:
				velocity = Vector2.ZERO
				current_hold = closest_hold
				return
		
		# Handle jump.
		var coyote_timer: Timer = %"Coyote Timer" as Timer
		if was_on_floor and not is_on_floor():
			coyote_timer.wait_time = coyote_time
			coyote_timer.start()
		
		var has_recently_left_ground: bool = coyote_timer.time_left != 0
		
		if (is_on_floor() or has_recently_left_ground) and Input.is_action_just_pressed("jump"):
			was_on_floor = false
			velocity.y = jump_velocity
		else:
			was_on_floor = is_on_floor()
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_direction: float = Input.get_axis("move_left", "move_right")
		
		if input_direction: #if we're tryna move
			if sign(input_direction) != sign(velocity.x):
				velocity.x = 0 # for instant turning around
			if abs(velocity.x) < max_speed:
				velocity.x += input_direction * acceleration * delta
		else: #if we aint tryna move
			velocity.x = move_toward(velocity.x, 0, deceleration * delta) #slow down
		
		#flipping. Used answer from here: https://forum.godotengine.org/t/why-my-character-scale-keep-changing/13909/5
		if input_direction > 0:
			transform.x.x = 1
		elif input_direction < 0:
			transform.x.x = -1 
	
	if current_hold:
		var aim_dir: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
		
		var holding_cieling: bool = abs(current_hold.rotation_degrees - 180) < 1
		if holding_cieling:
			global_position = current_hold.global_position - (top_hand_point.global_position - global_position)
			if aim_dir.x > 0:
				transform.x.x = 1
			elif aim_dir.x < 0:
				transform.x.x = -1 
		else:
			global_position = current_hold.global_position - (side_hand_point.global_position - global_position)
			if abs(current_hold.rotation_degrees - 90) < 1:
				transform.x.x = -1
			elif abs(current_hold.rotation_degrees - 270) < 1:
				transform.x.x = 1
		
		if Input.is_action_just_released("jump"):
			if abs(aim_dir.y) == 0:
				velocity = leap_velocity * aim_dir
				gravity_reduce_timer.wait_time = 0.15
				gravity_reduce_timer.start()
			else:
				velocity = leap_velocity * aim_dir
			current_hold = null
	
	update_animations()
	move_and_slide()

@onready var sprite_animator: AnimatedSprite2D = %"Sprite Animator" as AnimatedSprite2D

func update_animations() -> void:
	var is_downsliding: bool = is_on_wall() and velocity.y > 0
	if is_on_floor():
		if abs(velocity.x) > 10:
			sprite_animator.play("walk")
		else:
			sprite_animator.play("idle")
	elif current_hold:
		var holding_cieling: bool = abs(current_hold.rotation_degrees - 180) < 1
		if holding_cieling:
			sprite_animator.play("hang_top")
		else:
			sprite_animator.play("hang_side")
	elif is_downsliding:
		sprite_animator.play("downslide")
	else:
		sprite_animator.play("jump")
		
		

func try_squash() -> void:
	if is_on_floor():
		die()

func die() -> void:
	var highest_campfire: Campfire = null
	for campfire: Campfire in campfires:
		if campfire.is_lit == false: continue
		if highest_campfire == null:
			highest_campfire = campfire
			continue
		if global_position.distance_to(campfire.global_position) > global_position.distance_to(highest_campfire.global_position):
			highest_campfire = campfire
	
	if highest_campfire:
		#respawn
		global_position = highest_campfire.global_position
	else:
		print("you die for real")
		queue_free()
		

func apply_gravity(delta: float) -> void:
	if is_on_floor(): return
	if velocity.y > terminal_velocity: return
	
	var is_downsliding: bool = is_on_wall() and velocity.y > 0
	var gravity_reduced: bool = gravity_reduce_timer.time_left > 0
	if is_downsliding:
		velocity += get_gravity()*0.5 * delta
		velocity.y = min(velocity.y, downslide_speed)
	elif gravity_reduced:
		velocity += get_gravity()*0.5 * delta
		velocity.y = min(velocity.y, downslide_speed)
	else:
		velocity += get_gravity()*3 * delta

func on_hitbix_hit(area: Area2D) -> void:
	if area.is_in_group("spike"):
		die()
	if area is Campfire:
		if campfires.has(area): return #skip if we already have it
		area.is_lit = true
		campfires.append(area)
