extends Sprite2D
@onready var banana: Sprite2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Choque con la banana")
	banana.visible = false #ocultar banana
	#desactivar colision
	collision_shape_2d.call_deferred("set","disabled",true)
	body.spin_effect_init() 
