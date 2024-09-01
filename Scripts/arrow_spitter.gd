extends Area2D
@export var arrow_prefab : PackedScene
@export var fire_rate : float = 1

func _ready() -> void:
	var parent: Node = get_parent()
	if parent is Placeable:
		parent.falling.connect($SpitTimer.start)
	else:
		$SpitTimer.start(fire_rate)


func _on_spit_timer_timeout() -> void:
	await get_tree().create_timer(0.5).timeout
	var spawned_obj : Arrow = arrow_prefab.instantiate() as Arrow
	add_child(spawned_obj)
	spawned_obj.position = $SpitPoint.position
	spawned_obj.rotation = deg_to_rad(90)
