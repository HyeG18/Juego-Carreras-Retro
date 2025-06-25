extends VehicleBody3D

# Rotacion de las ruedas al girar. 0.8 = 45º
const MAX_STEER = 0.8;
const Power = 300;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("derecha", "izquierda") * MAX_STEER, delta * 2.5);
	engine_force = Input.get_axis("retroceder", "acelerar") * Power;
	
	
