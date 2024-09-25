class_name Harpoon
extends Area2D

@onready var tripwire: RayCast2D = $Tripwire
var launched: bool = false
var harpoon_landed: bool = false
@onready var harpoon: Node2D = $Harpoon
@onready var rope: Line2D = $Rope

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rope.visible = false
	rope.clear_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var parent: Node = get_parent()
	if parent is Placeable:
		if parent.state != Placeable.PlaceState.PLACED:
			return
	if !launched:
		var hit_obj: Object = tripwire.get_collider()
		if hit_obj is Placeable:
			if hit_obj.state == Placeable.PlaceState.FALLING:
				if hit_obj.targeted_by_harpoon: return #if another harpoon already has plans
				hit_obj.targeted_by_harpoon = true
				var direction: Vector2 = Vector2.from_angle( global_rotation - deg_to_rad(90))
				direction = direction.round()
				hit_obj.enter_harpooned(0.15,-direction)
				launched = true
				rope.visible = true
				var tween: Tween = get_tree().create_tween()
				tween.tween_property(harpoon, "global_position", tripwire.get_collision_point(), 0.16)
				await tween.finished
				harpoon_landed = true
				var cell_hit_pos: Vector2 = hit_obj.get_closest_cell_center(harpoon.global_position)
				var cell_local_pos: Vector2 = cell_hit_pos - hit_obj.global_position
				if direction.y == 0: 
					hit_obj.global_position.y  = global_position.y - cell_local_pos.y
				else:
					hit_obj.global_position.x  = global_position.x- cell_local_pos.x
				harpoon.reparent(hit_obj)
	else:
		if is_instance_valid(harpoon) && launched:
			if harpoon_landed:
				rope.points = [to_local(harpoon.global_position), Vector2.ZERO]
			else:
				rope.clear_points()
				var rope_resolution: float = 5 #make as high as possible. better for performance
				var frequency: float = 0.05 #lower for further apart waves
				var magnitude: float = 3 #higher for bigger waves
				var distance: float = to_local(harpoon.global_position).distance_to(Vector2.ZERO)
				var direction: Vector2 = Vector2.ZERO.direction_to(to_local(harpoon.global_position))
				var perpendicular_dir: Vector2 = direction.rotated(PI/2)
				for x: float in rangef(0.0,distance,rope_resolution):
					var y: float = sin(x*PI*frequency) * magnitude
					
					rope.add_point(direction*(distance-x) + perpendicular_dir*y)
		else:
			rope.visible = false

func rangef(start: float, end: float, step: float) -> Array[float]:
	var res: Array[float] = []
	var i : float = start
	while i < end:
		res.push_back(i)
		i += step
	return res
