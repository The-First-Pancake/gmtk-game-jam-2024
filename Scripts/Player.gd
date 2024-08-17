class_name Player
extends CharacterBody2D


var jump_velocity: float = -800.0
var acceleration: float = 3000
var deceleration: float = 4000
var max_speed: float = 700

var leap_velocity: float = 1300.0

var downslide_speed: float = 300
var current_hold: Node2D = null

var coyote_time: float = 0.1

var was_on_floor: bool = true

func _process(delta: float) -> void:
	if current_hold == null:
		# Add the gravity.
		if not is_on_floor():
			var is_downsliding: bool = is_on_wall() and velocity.y > 0
			if is_downsliding:
				velocity += get_gravity()*0.5 * delta
				velocity.y = min(velocity.y, downslide_speed)
			else:
				velocity += get_gravity()*3 * delta
		
		#grab holds
		if Input.is_action_just_pressed("jump"):
			var mid_air_hold_detector: Area2D = %"Mid-Air Hold Detector" as Area2D
			var grounded_hold_detector_2: Area2D = %"Grounded Hold Detector2" as Area2D
			
			var holds: Array[Area2D] = []
			if is_on_floor():
				holds = grounded_hold_detector_2.get_overlapping_areas()
			else:
				holds = mid_air_hold_detector.get_overlapping_areas()
			
			for hold in holds:
				if hold.is_in_group("hold"):
					velocity = Vector2.ZERO
					current_hold = hold as Node2D
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
			velocity.x += input_direction * acceleration * delta
			velocity.x = clamp(velocity.x,-max_speed, max_speed)
		else: #if we aint tryna move
			velocity.x = move_toward(velocity.x, 0, deceleration * delta) #slow down
		
		#flipping. Used answer from here: https://forum.godotengine.org/t/why-my-character-scale-keep-changing/13909/5
		if input_direction > 0:
			transform.x.x = 1
		elif input_direction < 0:
			transform.x.x = -1 
	
	if current_hold:
		var hand_point: Marker2D = %"Hand Point" as Marker2D
		print(hand_point.position)
		print(global_position)
		global_position = current_hold.global_position - (hand_point.global_position - global_position)
		
		var aim_dir: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
		if Input.is_action_just_released("jump"):
			velocity = leap_velocity * aim_dir
			current_hold = null
	

	move_and_slide()

func try_squash() -> void:
	if is_on_floor():
		queue_free()
