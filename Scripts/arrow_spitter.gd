extends Area2D
@export var arrow_prefab : PackedScene

func _ready() -> void:
	var parent: Node = get_parent()
	if parent is Placeable:
		parent.placed.connect(check_if_blocked)
		parent.falling.connect($SpitTimer.start)
	else:
		$SpitTimer.start()

func _on_body_entered(body: Node2D) -> void:
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

func _on_spit_timer_timeout() -> void:
	$"Hawk-tuahSRaUp2l".play()
	await get_tree().create_timer(0.5).timeout
	var spawned_obj : Arrow = arrow_prefab.instantiate() as Arrow
	add_child(spawned_obj)
	spawned_obj.position = $SpitPoint.position
	spawned_obj.rotation = deg_to_rad(90)
