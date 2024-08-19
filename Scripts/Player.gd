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
var idols_collected: int = 0

var was_on_floor: bool = true

var campfires: Array[Campfire] = []

@onready var side_hand_point: Marker2D = %"Side Hand Point" as Marker2D
@onready var top_hand_point: Marker2D = %"Top Hand Point" as Marker2D

@onready var slide_particles: GPUParticles2D = $"Slide Particles" as GPUParticles2D
@onready var jump_particles: GPUParticles2D = $"Jump Particles" as GPUParticles2D
@onready var land_particles: GPUParticles2D = $"Land Particles" as GPUParticles2D
@onready var hold_release_particles: GPUParticles2D = $"Hold Release Particles" as GPUParticles2D

@onready var gravity_reduce_timer: Timer = %"Gravity Reduce Timer" as Timer
@onready var targeting_arrow: Sprite2D = $"Targeting Arrow"

func _ready() -> void:
	GameManager.player = self
	await get_tree().create_timer(0.3).timeout
	velocity.x = 900

var is_downsliding: bool

func _process(delta: float) -> void:
	if dying: return
	targeting_arrow.visible = false
	is_downsliding = is_on_wall() and velocity.y > 0
	
	if current_hold == null:
		movement(delta)
	if current_hold:
		holding_behavior()
	
	update_animations()
	move_and_slide()

func movement(delta: float) -> void:
	# Add the gravity.
	apply_gravity(delta)
	
	#grab holds
	if Input.is_action_just_pressed("jump") or (Input.is_action_pressed("jump") and is_downsliding):
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
			if abs(hold.global_rotation_degrees) < 1: continue #if the hold is upright we can't grab it
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
	
	if !was_on_floor and is_on_floor():
		land_particles.restart()
	
	if (is_on_floor() or has_recently_left_ground) and Input.is_action_just_pressed("jump"):
		jump_particles.restart()
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

func holding_behavior() -> void:
	var aim_dir: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
	
	#targeting arrow
	if aim_dir != Vector2.ZERO:
		targeting_arrow.visible = true
		if transform.x.x == 1:
			targeting_arrow.global_rotation = aim_dir.angle() + PI/2
		else:
			targeting_arrow.global_rotation = aim_dir.angle() - PI/2
	
	var holding_cieling: bool = abs(angle_difference(current_hold.global_rotation, deg_to_rad(180))) < deg_to_rad(1)
	if holding_cieling:
		global_position = current_hold.global_position - (top_hand_point.global_position - global_position)
		if aim_dir.x > 0:
			transform.x.x = 1
		elif aim_dir.x < 0:
			transform.x.x = -1 
	else:
		global_position = current_hold.global_position - (side_hand_point.global_position - global_position)
		if abs(angle_difference(current_hold.global_rotation, deg_to_rad(90))) < deg_to_rad(1):
			transform.x.x = -1
		elif abs(angle_difference(current_hold.global_rotation, deg_to_rad(270))) < deg_to_rad(1):
			transform.x.x = 1
	
	if Input.is_action_just_released("jump"):
		hold_release_particles.restart()
		if abs(aim_dir.y) == 0:
			velocity = leap_velocity * aim_dir
			gravity_reduce_timer.wait_time = 0.15
			gravity_reduce_timer.start()
		else:
			velocity = leap_velocity * aim_dir
		current_hold = null
	

@onready var sprite_animator: AnimatedSprite2D = %"Sprite Animator" as AnimatedSprite2D
@onready var griddy_timer: Timer = %"Griddy Timer" as Timer

func update_animations() -> void:
	if sprite_animator.animation != "idle" and sprite_animator.animation != "dance":
		griddy_timer.start()
	
	slide_particles.emitting = false
	if current_hold:
		var holding_cieling: bool = abs(angle_difference(current_hold.global_rotation, deg_to_rad(180))) < deg_to_rad(1)
		if holding_cieling:
			sprite_animator.play("hang_top")
		else:
			sprite_animator.play("hang_side")
	elif is_on_floor():
		if abs(velocity.x) > 10:
			sprite_animator.play("walk")
		else:
			if griddy_timer.time_left == 0:
				sprite_animator.play("dance")
			else:
				sprite_animator.play("idle")
	elif is_downsliding:
		sprite_animator.play("downslide")
		slide_particles.emitting = true
	else:
		if abs(velocity.x) > 750:
			sprite_animator.play("jump_reach")
		else:
			if abs(velocity.y) < 200:
				sprite_animator.play("jump_hang")
			elif velocity.y > 0:
				sprite_animator.play("jump_decend")
			else:
				sprite_animator.play("jump_up")

func try_squash() -> void:
	if is_on_floor():
		die()

var dying: bool = false
func die() -> void:
	if dying:return
	dying = true
	current_hold = null
	sprite_animator.play("die")
	
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position:y", global_position.y - 80, 0.3)
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position:y", global_position.y + 600, 0.5)
	await tween.finished

	
	
	var highest_campfire: Campfire = null
	for campfire: Campfire in campfires:
		if campfire == null: continue
		if campfire.is_lit == false: continue
		if highest_campfire == null:
			highest_campfire = campfire
			continue
		if campfire.global_position.y < highest_campfire.global_position.y:
			highest_campfire = campfire
	
	if highest_campfire:
		#respawn
		global_position = highest_campfire.global_position
	else:
		print("you die for real")
		get_tree().reload_current_scene()
		queue_free()
	
	dying = false

func apply_gravity(delta: float) -> void:
	if is_on_floor(): return
	if velocity.y > terminal_velocity: return
	
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
	if area.is_in_group("water"):
		die()
	if area.is_in_group("idol"):
		area.queue_free()
		idols_collected += 1
		return
	if area is Campfire:
		if campfires.has(area): return #skip if we already have it
		area.is_lit = true
		campfires.append(area)
