extends CSGBox3D

func _ready():
	print("Script ejecutándose en: ", name)
	
	# Crear material
	var nuevo_material = StandardMaterial3D.new()
	nuevo_material.albedo_color = Color(0, 0, 1)  # Azul puro
	
	# Propiedades para hacerlo muy visible
	nuevo_material.metallic = 0.0
	nuevo_material.roughness = 0.5
	nuevo_material.emission_enabled = true  # ¡Hace que brille en la oscuridad!
	nuevo_material.emission = Color(0, 0, 0.5)  # Emisión azul suave
	
	material = nuevo_material
	print("Material asignado")
	
	# Verificar si realmente se asignó
	if material:
		print("Material existe:", material.resource_name)
	else:
		print("ERROR: Material no asignado")
