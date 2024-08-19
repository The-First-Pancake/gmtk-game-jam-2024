extends CharacterBody2D

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
	$CollisionShape2D.disabled = true
