extends CharacterBody2D


const SPEED = 195.0
const JUMP_VELOCITY = -400.0
const RUN_SPEED = 300

var debe_correr: bool = false

#variables para que el jugador gire
var is_spinning = false
var spin_timer = 0.7  # duración del giro en segundos
var spin_speed = 10.0  # velocidad de giro

signal run_effect

signal spin_effect

func spin_effect_init() -> void:
	spin_effect.emit()
	print("spin_effect_init() ")

func run_effect_init() -> void:
	run_effect.emit()
	print("run_effect_init() ")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction *(RUN_SPEED if debe_correr else SPEED ) 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#spin part
	if is_spinning:
		rotation += spin_speed * delta
		spin_timer -= delta
		if spin_timer <= 0:
			is_spinning = false
			spin_timer = 0.5	

	move_and_slide()
