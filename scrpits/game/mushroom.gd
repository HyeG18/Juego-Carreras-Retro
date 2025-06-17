extends Sprite2D
@onready var mushroom: Sprite2D =  $"."
@onready var collisionShape: CollisionShape2D =  $"Area2D/CollisionShape2D"

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Choque con el honguito")
	mushroom.visible = false #ocultar honguito
	#desactivar colision
	collisionShape.call_deferred("set","disabled",true)
	body.run_effect_init() 
