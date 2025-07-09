extends StaticBody3D

func _init():
	collision_layer = 1  # Capa 1: Environment
	collision_mask = 2    # Detecta capa 2: Vehicles

func _ready():
	# Crear forma de colisión para rectas
	create_straight_barrier(Vector3(0, 0, 50), Vector3(10, 0, 50), 3.0)
	
	# Crear forma de colisión para curvas
	create_curve_barrier(Vector3(20, 0, 50), 15.0, 90.0, 3.0)

func create_straight_barrier(start: Vector3, end: Vector3, height: float):
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	var length = start.distance_to(end)
	var center = (start + end) / 2
	var direction = (end - start).normalized()
	
	box_shape.size = Vector3(length, height, 0.5)
	collision_shape.shape = box_shape
	
	add_child(collision_shape)
	collision_shape.global_position = center
	collision_shape.look_at(end, Vector3.UP)

func create_curve_barrier(center: Vector3, radius: float, angle_degrees: float, height: float):
	var segment_count = max(4, int(angle_degrees / 15))
	var angle_step = deg_to_rad(angle_degrees / segment_count)
	
	for i in range(segment_count):
		var angle = i * angle_step
		var x = center.x + radius * cos(angle)
		var z = center.z + radius * sin(angle)
		
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		
		box_shape.size = Vector3(radius * angle_step, height, 0.5)
		collision_shape.shape = box_shape
		
		add_child(collision_shape)
		collision_shape.global_position = Vector3(x, center.y, z)
		collision_shape.rotation.y = angle + PI/2
