extends CharacterBody2D


const SPEED = 195.0
const JUMP_VELOCITY = -400.0
const RUN_SPEED = 300

var debe_correr: bool = false

signal run_effect

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

	move_and_slide()
