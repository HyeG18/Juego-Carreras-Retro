# ui_manager.gd
extends Node # Un Node base es suficiente si solo gestiona el cambio de escenas.
			 # Si también contiene elementos visuales de UI, podría extender CanvasLayer.

# Rutas a tus escenas de UI y las escenas del juego.
@export_file("*.tscn") var start_scene_path: String = "res://scenes/ui/start.tscn"
@export_file("*.tscn") var main_menu_scene_path: String = "res://scenes/ui/menu.tscn"
@export_file("*.tscn") var single_player_game_scene_path: String = "res://scenes/game/single_player_game.tscn" # Escena de juego Single Player
@export_file("*.tscn") var multiplayer_game_scene_path: String = "res://scenes/game/multiplayer_game.tscn" # Escena de juego Multiplayer

var current_scene_path: String = "" # La ruta de la escena que está actualmente activa
var scene_history: Array[String] = [] # Almacena las rutas de las escenas de UI visitadas para retroceder

# --- Variables para la lógica del Menú Principal ---
var main_menu_options: Array[String] = ["single_player", "multiplayer"]
var current_main_menu_selection_index: int = 0

# Señal para que la escena del menú principal sepa qué opción está seleccionada
signal main_menu_selection_changed(new_index: int)


func _ready() -> void:
	# Refactorización para asegurar que current_scene_path se inicialice correctamente.
	# Si ya hay una escena cargada (ej. si Main Scene está configurada en Project Settings),
	# usamos esa. De lo contrario, cargamos la escena de inicio.
	if get_tree().current_scene != null:
		current_scene_path = get_tree().current_scene.scene_file_path
		print("UI Manager listo. Escena inicial: %s" % current_scene_path)
		# Si la escena cargada no es la de inicio, navegamos a ella
		if current_scene_path != start_scene_path:
			_change_scene_internal(start_scene_path, false)
	else:
		# Si no hay escena cargada (ej. ejecutando desde línea de comandos sin --main-scene)
		print("UI Manager: No hay escena principal cargada, cargando start_scene.tscn.")
		_change_scene_internal(start_scene_path, false) # Cargar la escena de inicio


# Esta función se llama para cualquier evento de entrada que NO haya sido consumido por otros nodos.
func _unhandled_input(event: InputEvent) -> void:
	# Manejo de navegación izquierda/derecha SOLO si estamos en el menú principal
	if current_scene_path == main_menu_scene_path:
		if event.is_action_pressed("ui_izquierda"):
			_handle_menu_navigation(-1) # Mover selección a la izquierda
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_derecha"):
			_handle_menu_navigation(1) # Mover selección a la derecha
			get_viewport().set_input_as_handled()

	# Aceptar (Botón X del PS4 o Enter/Spacebar)
	if event.is_action_pressed("ui_aceptar"):
		_handle_accept_input()
		get_viewport().set_input_as_handled()
	
	# Atrás (Botón O del PS4 o Escape/Backspace)
	if event.is_action_pressed("ui_cancelar"):
		_handle_cancel_input()
		get_viewport().set_input_as_handled()


# --- Funciones Públicas para ser llamadas desde otros scripts si es necesario ---

func navigate_to_scene(path: String) -> void:
	change_scene_and_manage_history(path)

# --- Lógica Interna de Navegación ---

func change_scene_and_manage_history(path: String) -> void:
	if current_scene_path != "" and current_scene_path != path:
		scene_history.append(current_scene_path)
		print("Añadiendo a historial: %s" % current_scene_path)
	
	_change_scene_internal(path, true)


func _handle_accept_input() -> void:
	print("Input ACEPTAR detectado.")
	
	if current_scene_path == start_scene_path:
		print("Desde Pantalla de Inicio -> Menú Principal")
		change_scene_and_manage_history(main_menu_scene_path)
		# Resetear la selección del menú al entrar al menú principal
		current_main_menu_selection_index = 0
		emit_signal("main_menu_selection_changed", current_main_menu_selection_index)
	elif current_scene_path == main_menu_scene_path:
		var selected_option = main_menu_options[current_main_menu_selection_index]
		if selected_option == "single_player":
			print("Desde Menú Principal -> Iniciar Juego Single Player")
			scene_history.clear() # Limpiar historial de UI al ir al juego
			_change_scene_internal(single_player_game_scene_path, false)
		elif selected_option == "multiplayer":
			print("Desde Menú Principal -> Iniciar Juego Multiplayer")
			scene_history.clear() # Limpiar historial de UI al ir al juego
			_change_scene_internal(multiplayer_game_scene_path, false)
	else:
		print("Aceptar no definido para la escena actual: %s" % current_scene_path)


func _handle_cancel_input() -> void:
	print("Input CANCELAR detectado. Historial de escenas: %s" % scene_history)
	
	if scene_history.size() > 0:
		var previous_scene_path = scene_history.pop_back()
		print("Volviendo a: %s" % previous_scene_path)
		_change_scene_internal(previous_scene_path, false)
	else:
		# Si el historial está vacío
		if current_scene_path == start_scene_path:
			print("Ya estás en la Pantalla de Inicio, saliendo de la aplicación.")
			get_tree().quit() # Si estás en la pantalla de inicio y no hay historial, salir del juego
		elif current_scene_path == main_menu_scene_path:
			print("Desde Menú Principal -> Volviendo a Pantalla de Inicio.")
			_change_scene_internal(start_scene_path, false)
		else:
			print("Historial vacío y no en Start/Main Menu. Volviendo a Pantalla de Inicio.")
			_change_scene_internal(start_scene_path, false)


func _handle_menu_navigation(direction: int) -> void:
	# direction: -1 para izquierda, 1 para derecha
	var new_index = current_main_menu_selection_index + direction
	
	# Asegurarse de que el índice se mantenga dentro de los límites
	new_index = wrap(new_index, 0, main_menu_options.size()) # wrap() para bucle infinito (0, 1, 0, 1...)
	
	if new_index != current_main_menu_selection_index:
		current_main_menu_selection_index = new_index
		print("Selección de menú principal: %s (Índice: %d)" % [main_menu_options[current_main_menu_selection_index], current_main_menu_selection_index])
		emit_signal("main_menu_selection_changed", current_main_menu_selection_index)


func _change_scene_internal(path: String, _add_to_history: bool) -> void: # Corrected parameter name
	print("DEBUG: Intentando cambiar a escena: %s" % path) # Debug print
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		printerr("ERROR: Fallo al cambiar de escena a: %s (Código de error: %s)" % [path, error]) # More specific error message
		current_scene_path = "" # Reset if load failed
	else:
		await get_tree().process_frame
		if get_tree().current_scene != null:
			current_scene_path = get_tree().current_scene.scene_file_path
			print("DEBUG: Escena cambiada exitosamente a: %s" % current_scene_path) # Debug print
		else:
			printerr("ERROR: Después de cambiar a %s, current_scene es null. Esto indica que la escena no se cargó correctamente." % path) # More specific error message
			current_scene_path = "" # Reset if not loaded
