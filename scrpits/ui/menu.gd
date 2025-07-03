# main_menu.gd
extends Control # Asegúrate de que el nodo raíz de tu menú (Menu) sea un Control o similar

# Ajusta las rutas para que coincidan con tu estructura de nodos
@onready var single_player_button: Control = $"HBoxContainer/singleplayer" 
@onready var multiplayer_button: Control = $"HBoxContainer/multiplayer" 

var menu_options_nodes: Array[Control] # Array para facilitar el acceso a los nodos de las opciones

func _ready() -> void:
	# Asegúrate de que el Autoload 'ui_manager' exista y esté configurado correctamente.
	# La corrección es cambiar 'UIManager' a 'ui_manager' para que coincida con el nombre del Autoload.
	if ui_manager: # Corrected from UIManager to ui_manager
		# Conecta la señal del ui_manager para saber cuándo cambia la selección
		ui_manager.main_menu_selection_changed.connect(_on_main_menu_selection_changed) # Corrected from UIManager to ui_manager
		
		# Inicializa el array de nodos de opciones en el orden que ui_manager espera
		ui_manager.current_main_menu_selection_index = 0 # Ensure index is reset when menu is entered
		menu_options_nodes = [single_player_button, multiplayer_button]
		
		# Asegura que la selección inicial se muestre correctamente
		_on_main_menu_selection_changed(ui_manager.current_main_menu_selection_index) # Corrected from UIManager to ui_manager
	else:
		printerr("ERROR: ui_manager (Autoload) no encontrado. Asegúrate de que esté configurado correctamente en Project Settings -> Autoload con el nombre 'ui_manager'.")

func _on_main_menu_selection_changed(new_index: int) -> void:
	# Define una escala normal y una escala para el botón seleccionado
	var normal_scale = Vector2(1.0, 1.0)
	var selected_scale = Vector2(1.1, 1.1) # Escala un 10% más grande

	# Deshabilita el resaltado de la opción anterior y resalta la nueva
	for i in range(menu_options_nodes.size()):
		if menu_options_nodes[i]:
			var current_node = menu_options_nodes[i]
			
			# Resetea siempre la escala y el color de todos los nodos al inicio del bucle.
			# Esto asegura que cualquier tween anterior se "sobrescriba" y el estado sea limpio.
			# Se eliminan las líneas de cambio de color y escala.
			current_node.modulate = Color.WHITE # Asegura que todos los botones estén blancos por defecto
			current_node.scale = normal_scale # Asegura que todos los botones estén en escala normal por defecto

			if i == new_index:
				# Si quieres algún tipo de feedback visual, puedes colocarlo aquí.
				# Por ejemplo, cambiar una textura, mostrar un icono, etc.
				# current_node.modulate = Color.YELLOW # Eliminado según tu petición
				# var tween = create_tween() # Eliminado según tu petición
				# tween.set_ease(Tween.EASE_OUT) # Eliminado según tu petición
				# tween.set_trans(Tween.TRANS_QUART) # Eliminado según tu petición
				# tween.tween_property(current_node, "scale", selected_scale, 0.15) # Eliminado según tu petición
				
				print("Visualmente seleccionado: %s" % current_node.name)
			# No se necesita un 'else' aquí para la escala, ya que todos los no seleccionados
			# ya se han restablecido al inicio del bucle.
