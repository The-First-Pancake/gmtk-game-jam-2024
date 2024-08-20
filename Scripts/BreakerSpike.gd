extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent: Node = get_parent()
	if parent is Placeable:
		parent.placed.connect(check_if_blocked)
		parent.falling.connect(enable_collider)
	else:
		enable_collider()

func enable_collider() -> void:
	$CollisionPolygon2D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().state == Placeable.PlaceState.PLACED: enable_collider()

func _on_body_entered(body: Node2D) -> void:
	if (body is Placeable and (body != get_parent())):
		body.destroy($ShatterPoint.global_position)
	else:
		check_if_blocked()

func check_if_blocked() -> void:
	var parent: Node = get_parent()
	if parent is Placeable:
		if parent.state != parent.PlaceState.PLACED:
			return
	
	var bodies: Array[Node2D] = get_overlapping_bodies()
	for body: Node2D in bodies:
		if body is Placeable:
			if body.state != body.PlaceState.PLACED:
				continue
		if body is Placeable or body.is_in_group("terrain"):
			if body != get_parent():
				queue_free()
