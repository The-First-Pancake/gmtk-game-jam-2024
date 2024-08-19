extends CharacterBody2D

const max_roation_on_hit = 10
@export var speed : float = 300.0

func _physics_process(delta: float) -> void:
	if (speed != 0):
		velocity = speed * Vector2.DOWN.rotated(rotation)
		move_and_slide()
		var collision : KinematicCollision2D = get_last_slide_collision()
		if collision:
			self.reparent(collision.get_collider())
			stick_in_object()
		
func stick_in_object() -> void:
	speed = 0
	show_behind_parent = true
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	$ArrowSingle.visible = true
	$ArrowSingle.show_behind_parent = true
	# rotate a bit
	var rotate_amount : float = randf_range(-1, 1) * max_roation_on_hit
	print(sign, rotate_amount)
	rotate(deg_to_rad(rotate_amount))
