extends Node

# Configuración de rutas (asegúrate que estas rutas sean correctas)
@export_file("*.tscn") var start_scene_path: String = "res://scenes/ui/start.tscn"
@export_file("*.tscn") var main_menu_scene_path: String = "res://scenes/ui/menu.tscn"
@export_file("*.tscn") var single_player_game_scene_path: String = "res://scenes/game/single_player_game.tscn"
@export_file("*.tscn") var multiplayer_game_scene_path: String = "res://scenes/game/game2P.tscn"


var current_scene_path: String = ""
var scene_history: Array[String] = []
var main_menu_options: Array[String] = ["single_player", "multiplayer"]
var current_main_menu_selection_index: int = 0


# Señal para que la escena del menú principal sepa qué opción está seleccionada
signal main_menu_selection_changed(new_index: int)


func _ready() -> void:
	if get_tree().current_scene != null:
		current_scene_path = get_tree().current_scene.scene_file_path
		print("Escena actual al inicio: ", current_scene_path)
		
		# Si no estamos en la escena de inicio, cargarla
		if current_scene_path != start_scene_path:
			await _change_scene_internal(start_scene_path, false)
	else:
		print("No hay escena principal cargada, cargando inicio")
		await _change_scene_internal(start_scene_path, false)



# Esta función se llama para cualquier evento de entrada que NO haya sido consumido por otros nodos.
func _unhandled_input(event: InputEvent) -> void:
	if current_scene_path == main_menu_scene_path:
		if event.is_action_pressed("ui_izquierda"):
			_handle_menu_navigation(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_derecha"):
			_handle_menu_navigation(1)
			get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_aceptar"):
		_handle_accept_input()
		get_viewport().set_input_as_handled()
	
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
	print("Botón Aceptar presionado en escena: ", current_scene_path)
	
	if current_scene_path == start_scene_path:
		print("Navegando a menú principal")
		await change_scene_and_manage_history(main_menu_scene_path)
		current_main_menu_selection_index = 0
		emit_signal("main_menu_selection_changed", current_main_menu_selection_index)
	elif current_scene_path == main_menu_scene_path:
		var selected_option = main_menu_options[current_main_menu_selection_index]
		print("Opción seleccionada: ", selected_option)
		
		if selected_option == "single_player":
			print("Cargando single player...")
			scene_history.clear()
			await _change_scene_internal(single_player_game_scene_path, false)
		elif selected_option == "multiplayer":
			print("Cargando multiplayer...")
			scene_history.clear()
			await _change_scene_internal(multiplayer_game_scene_path, false)




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
	# Store previous index for comparison
	var previous_index = current_main_menu_selection_index
	# Calculate new index with wrapping
	var new_index = current_main_menu_selection_index + direction
	new_index = wrap(new_index, 0, main_menu_options.size())
	# Only update if the index actually changed
	if new_index != previous_index:
		current_main_menu_selection_index = new_index
		print("Navegación: Cambiando a opción ", main_menu_options[current_main_menu_selection_index]," (Índice: ", current_main_menu_selection_index, ")")
	# Emit the signal to update visual feedback
		emit_signal("main_menu_selection_changed", current_main_menu_selection_index)
	else:
		print("Navegación: Ya en el límite del menú")


func _change_scene_internal(path: String, add_to_history: bool) -> void:
	print("Intentando cambiar a escena: ", path)
	
	# Verificar si el archivo existe
	if not ResourceLoader.exists(path):
		printerr("ERROR: La escena no existe en la ruta: ", path)
		return
	
	if add_to_history and current_scene_path != "" and current_scene_path != path:
		scene_history.append(current_scene_path)
		print("Añadido al historial: ", current_scene_path)
	
	var error = get_tree().change_scene_to_file(path)
	
	if error != OK:
		printerr("ERROR al cambiar escena (código ", error, "): ", path)
		return
	
	# Esperar a que la escena esté realmente cargada
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout # Pequeña espera adicional para asegurar la carga
	
	if get_tree().current_scene != null:
		current_scene_path = get_tree().current_scene.scene_file_path
		print("Escena cambiada con éxito a: ", current_scene_path)
	else:
		printerr("ERROR: Escena cambiada pero current_scene es null")
