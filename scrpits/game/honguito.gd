extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Nissan GTR":
		if body.has_method("apply_speed_boost"):
			body.apply_speed_boost(2.0, 5.0)  # Multiplicador de velocidad, duración en segundos
			print("Choque con el honguito")
		queue_free()  # Elimina el power-up de la escena
