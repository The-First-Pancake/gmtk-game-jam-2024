class_name Squashable
extends Node

@export var delete_parent_when_squashed: bool = true
@onready var squashable_parent: Area2D = $".."
signal squashed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	squashable_parent.area_entered.connect(func(_area: Area2D)->void:
		check_for_squash()
	)
	squashable_parent.body_entered.connect(func(_body: Node2D)->void:
		check_for_squash()
	)
	if squashable_parent.get_parent() is Placeable:
		squashable_parent.get_parent().placed.connect(check_for_squash)

func check_for_squash() -> void:
	var parent: Node = squashable_parent.get_parent()
	if parent is Placeable:
		if parent.state != parent.PlaceState.PLACED:
			return
	
	var bodies: Array[Node2D] = squashable_parent.get_overlapping_bodies()
	for body: Node2D in bodies:
		if body is Placeable:
			if body.state != body.PlaceState.PLACED:
				if body.state == body.PlaceState.FALLING:
					await body.placed
					check_for_squash()
					return
		if body is Placeable or body.is_in_group("terrain"):
			if body != parent:
				squashed.emit()
				if delete_parent_when_squashed:
					squashable_parent.queue_free()
