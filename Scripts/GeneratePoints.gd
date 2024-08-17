extends Node

var units_per_block : int = 30
@export var number_of_holds : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_polygon : CollisionPolygon2D = $"../CollisionPolygon2D"
	var collision_points : PackedVector2Array = collision_polygon.polygon
	
	var generated_points : PackedVector2Array = generateHoldPoints(collision_points)
	print(generated_points)
	placeTestPoints(generated_points)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func placeTestPoints(points: PackedVector2Array) -> void:
	for point in points:
		var test_point_prefab : PackedScene = preload("res://Prefabs/test_point.tscn") as PackedScene
		var test_point : Node2D = test_point_prefab.instantiate()
		var parent : Node2D = $".."
		parent.add_child.call_deferred(test_point)
		test_point.position = point
		test_point.rotation = parent.rotation
	return

func generateHoldPoints(points: PackedVector2Array) -> PackedVector2Array:
	
	var created_points: PackedVector2Array
	
	for i in points.size():
		var next_index : int = i+1
		if (next_index == points.size()):
			next_index = 0 #loop back to first index when on the last point in the array
		var point1 : Vector2 = points[i]
		var point2 : Vector2 = points[next_index]
		var distance: float = point1.distance_to(point2)
		var direction : Vector2 = point1.direction_to(point2)
		print("Collision Point: ", point1)
		if (distance >= units_per_block):
			var distance_vector : Vector2 = Vector2(units_per_block, units_per_block)
			var working_point : Vector2 = point1 - ((distance_vector * direction) / 2)
			
			for j in range((distance/units_per_block)):
				var new_point : Vector2 = (distance_vector * direction) + working_point
				working_point = new_point
				print("Created point: ", new_point)
				created_points.push_back(new_point)
	
	#print(created_points)
	return created_points
