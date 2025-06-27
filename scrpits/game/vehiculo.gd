extends VehicleBody3D

# Rotacion de las ruedas al girar. 0.8 = 45º
const MAX_STEER = 0.8;
@export var base_power := 300.0
var Power := base_power
var speed_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	speed_timer = Timer.new()
	speed_timer.one_shot = true
	speed_timer.connect("timeout", Callable(self, "_on_speed_boost_end"))
	add_child(speed_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("derecha", "izquierda") * MAX_STEER, delta * 2.5);
	engine_force = Input.get_axis("retroceder", "acelerar") * Power;
	
func apply_speed_boost(multiplier: float, duration: float) -> void:
	Power = base_power * multiplier
	speed_timer.wait_time = duration
	speed_timer.start()

func _on_speed_boost_end() -> void:
	Power = base_power
	
	
