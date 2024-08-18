class_name Hold
extends Area2D

func _ready() -> void:
	var parent: Node = get_parent()
	if parent is Placeable:
		parent.placed.connect(check_if_blocked)

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
