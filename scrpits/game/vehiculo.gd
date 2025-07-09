extends VehicleBody3D

# Rotacion de las ruedas al girar. 0.8 = 45º
const MAX_STEER = 1.2;
@export var base_power := 300.0
@export var player_device_id: int = 0 # ID del dispositivo del mando (0 para el primer mando, 1 para el segundo, etc.)
@export var input_deadzone: float = 0.1 # Umbral para los joysticks y gatillos para evitar "drift"

var Power := base_power
var speed_timer: Timer
var is_spinning := false
var spin_timer: Timer

# Manejo de colisiones
var barrier_rebound_force := 25.0  # Fuerza del rebote contra barreras
var barrier_cooldown := 0.3        # Tiempo mínimo entre impactos
var last_barrier_hit_time := 0.0
var barrier_slowdown_factor := 0.6 # % de velocidad que se pierde al chocar


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
	spin_timer.one_shot = true # CORRECCIÓN AQUÍ: Cambiado de 'spin_shot' a 'spin_timer.one_shot'
	spin_timer.connect("timeout", Callable(self, "_on_spin_timeout"))
	add_child(spin_timer)
	
	print("Carro del Jugador %d (Device ID: %d) listo." % [player_device_id + 1, player_device_id])
	# Crear área de detección de colisiones
	var collision_area = Area3D.new()
	collision_area.name = "CollisionArea"
	collision_area.collision_layer = 0
	collision_area.collision_mask = 1  # Detecta capa Environment
	collision_area.body_entered.connect(_on_body_entered)
	
	# Crear forma de colisión ajustada al vehículo
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = Vector3(2.0, 1.0, 4.0)  # Ajusta según tu vehículo
	
	collision_area.add_child(collision_shape)
	add_child(collision_area)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_spinning:
		# Lógica de giro si el coche está "trompeando"
		steering = randf_range(-1.0, 1.0) * 0.8  # Gira aleatoriamente
		engine_force = 0  # Opcional: frena el coche mientras trompea
	else:
		var steer_input = 0.0
		var engine_input = 0.0
		
		# --- Obtener entradas del mando ---
		# Eje X del joystick izquierdo (0): -1 para izquierda, 1 para derecha
		var joystick_x = Input.get_joy_axis(player_device_id, 0)
		# Gatillo izquierdo L2 (4): 0 a 1 (cuando presionado)
		var l2_trigger = Input.get_joy_axis(player_device_id, 4)
		# Gatillo derecho R2 (5): 0 a 1 (cuando presionado)
		var r2_trigger = Input.get_joy_axis(player_device_id, 5)

		# --- Control de Giro (Steering) ---
		# Prioriza el joystick del mando si se mueve más allá de la deadzone
		if abs(joystick_x) > input_deadzone:
			steer_input = -joystick_x # ¡CORRECCIÓN AQUÍ! Invierte el eje X del joystick
		else:
			# Si no hay entrada significativa del joystick, usa el teclado (WASD)
			steer_input = Input.get_axis("derecha", "izquierda")
		
		# --- Fuerza del Motor (Engine Force) ---
		# Prioriza los gatillos del mando si alguno se presiona más allá de la deadzone
		if r2_trigger > input_deadzone or l2_trigger > input_deadzone:
			engine_input = r2_trigger - l2_trigger # R2 acelera (positivo), L2 retrocede (negativo)
		else:
			# Si no hay entrada significativa de los gatillos, usa el teclado (WASD)
			engine_input = Input.get_axis("retroceder", "acelerar")

		# Aplica el input combinado al volante y al motor
		steering = move_toward(steering, steer_input * MAX_STEER, delta * 2.5)
		engine_force = engine_input * Power


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

# --- Manejo de colisiones con barreras ---
func _on_body_entered(body: Node) -> void:
	# Solo reaccionar a barreras y cuando no estamos en estado de giro
	if body.is_in_group("track_barriers") and not is_spinning:
		var current_time = Time.get_ticks_msec() / 1000.0
		
		# Evitar múltiples detecciones rápidas
		if current_time - last_barrier_hit_time > barrier_cooldown:
			last_barrier_hit_time = current_time
			_handle_barrier_collision()

			
func _handle_barrier_collision():
	# Calcular dirección de rebote (opuesta a la dirección actual)
	var velocity_normalized = linear_velocity.normalized()
	
	# Evitar división por cero si la velocidad es muy baja
	if velocity_normalized.length() < 0.1:
		velocity_normalized = -global_transform.basis.z
	
	# Aplicar fuerza de rebote
	var bounce_direction = -velocity_normalized
	linear_velocity += bounce_direction * barrier_rebound_force
	
	# Reducir velocidad después del choque
	linear_velocity *= barrier_slowdown_factor
	
	# Pequeño efecto de giro aleatorio
	if randf() > 0.3:  # 70% de probabilidad de alterar la dirección
		steering += randf_range(-0.8, 0.8)
		steering = clamp(steering, -MAX_STEER, MAX_STEER)
	
