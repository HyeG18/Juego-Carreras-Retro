extends VehicleBody3D

# Rotacion de las ruedas al girar. 0.8 = 45º
const MAX_STEER = 1.2;
@export var base_power := 300.0
var Power := base_power
var speed_timer: Timer
var is_spinning := false
var spin_timer: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	#Timer del honguito
	speed_timer = Timer.new()
	speed_timer.one_shot = true
	speed_timer.connect("timeout", Callable(self, "_on_speed_boost_end"))
	add_child(speed_timer)
	#Timer de la banana
	spin_timer = Timer.new()
	spin_timer.one_shot = true
	spin_timer.connect("timeout", Callable(self, "_on_spin_timeout"))
	add_child(spin_timer)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("derecha", "izquierda") * MAX_STEER, delta * 2.5);
	engine_force = Input.get_axis("retroceder", "acelerar") * Power;
	#verificacion de la banana
	if is_spinning:
		steering = randf_range(-1.0, 1.0) * 0.8  # Gira aleatoriamente
		engine_force = 0  # Opcional: frena el coche
	else:
		steering = move_toward(steering, Input.get_axis("derecha", "izquierda") * MAX_STEER, delta * 2.5)
		engine_force = Input.get_axis("retroceder", "acelerar") * Power

#Funciones del honguito
func apply_speed_boost(multiplier: float, duration: float) -> void:
	Power = base_power * multiplier
	speed_timer.wait_time = duration
	speed_timer.start()

func _on_speed_boost_end() -> void:
	Power = base_power
	
#Funciones de la banana
func apply_spin_out(force: float, duration: float) -> void:
	is_spinning = true
	spin_timer.wait_time = duration
	spin_timer.start()

func _on_spin_timeout():
	is_spinning = false

	
