extends CharacterBody2D


var jump_velocity: float = -800.0
var acceleration: float = 3000
var deceleration: float = 4000
var max_speed: float = 700

var leap_velocity: float = 1200.0

var downslide_speed: float = 300
var current_hold: Node2D = null

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
		
		
		# Handle jump.
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		
		if not is_on_floor() and Input.is_action_just_pressed("jump"):
			var hold_detector: Area2D = %"Hold Detector" as Area2D
			var holds: Array[Area2D] = hold_detector.get_overlapping_areas()
			for hold in holds:
				if hold.is_in_group("hold"):
					current_hold = hold as Node2D
					break

		
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
	
	if current_hold:
		global_position = current_hold.global_position
		var aim_dir: Vector2 = Input.get_vector("move_left","move_right","move_up","move_right")
		if aim_dir != Vector2.ZERO and Input.is_action_just_pressed("jump"):
			velocity = leap_velocity * aim_dir
			current_hold == null
	
	move_and_slide()
