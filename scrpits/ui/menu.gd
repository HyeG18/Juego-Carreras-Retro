extends Control

@onready var single_player_button: TextureButton = $"HBoxContainer/singleplayer"
@onready var multiplayer_button: TextureButton = $"HBoxContainer/multiplayer"
@onready var buttons = [single_player_button, multiplayer_button]

func _ready():
	# Configura el foco inicial
	single_player_button.grab_focus()
	
	# Conecta señales de los botones
	for button in buttons:
		button.focus_entered.connect(_on_button_focus.bind(button))
		button.focus_exited.connect(_on_button_focus_exited.bind(button))
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))

func _on_button_focus(button: Button):
	# Efecto visual cuando el botón recibe foco (con control)
	button.modulate = Color(1.2, 1.2, 1.2)
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_LINEAR)

func _on_button_mouse_entered(button: Button):
	# Efecto visual cuando el mouse entra (y también toma foco)
	button.grab_focus()
	_on_button_focus(button)  # Reutilizamos la misma función

func _on_button_focus_exited(button: Button):
	# Restablece cuando pierde el foco
	button.modulate = Color.WHITE
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_LINEAR)
	
func _on_main_menu_selection_changed(new_index: int):
	# Highlight the selected button
	for i in range(buttons.size()):
		if i == new_index:
			buttons[i].modulate = Color(1.2, 1.2, 1.2)  # Highlight
			buttons[i].grab_focus()
		else:
			buttons[i].modulate = Color.WHITE # Normal
