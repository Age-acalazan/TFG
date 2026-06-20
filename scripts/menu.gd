extends Node2D

func _ready() -> void:
	$TablaClasificacion/SubmenuTablaClasificacion/Leaderboard.show_leaderboard()

func _on_jugar_simple_button_up():
	var partida = preload("res://escenas/partida.tscn").instantiate()
	var baraja_nodo = partida.get_node("Baraja")
	baraja_nodo.JQKA_numeros = $Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers.is_pressed()
	get_tree().root.add_child(partida)
	queue_free()
	get_tree().current_scene = partida

func _on_jugar_modificadores_button_up() -> void:
	# Se definen las variables que pasaremos a la escena
	var modificadores_activos : bool = true
	var flags_cartas : Dictionary[String,bool] = {}
	var num_cartas_extra : Dictionary[String,int] = {}
	var vida_max : int = 20
	
	#Se van obteniendo y asignando los valores de la interfaz
	var nodos_toggle_cartas = get_tree().get_nodes_in_group("ToggleCartas")
	for nodo in nodos_toggle_cartas:
		flags_cartas.set(nodo.get_name(),nodo.is_pressed())
	
	var nodos_sliders_cartas_extra = get_tree().get_nodes_in_group("SliderCartaExtra")
	for nodo in nodos_sliders_cartas_extra:
		num_cartas_extra.set(nodo.get_name(),nodo.get_value())
	
	vida_max = $Jugar/SubmenuModificadores/ScrollContainer/VBoxContainer/VidaMaxima/SliderVidaMax.get_value()
	
	# Se precarga la escena...
	var partida = preload("res://escenas/partida.tscn").instantiate()
	var baraja_nodo = partida.get_node("Baraja")
	baraja_nodo.JQKA_numeros = $Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers.is_pressed()
	# ...para seguidamente adignarlo los valores obtenidos
	baraja_nodo.modificadores_activos = modificadores_activos
	baraja_nodo.flags_cartas = flags_cartas
	baraja_nodo.num_cartas_extra = num_cartas_extra
	partida.vida_max = vida_max
	
	# Se cambia de escena
	get_tree().root.add_child(partida)
	queue_free()
	get_tree().current_scene = partida

func esconder_submenus():
	get_tree().get_nodes_in_group("Submenus").map(func(e):e.set_visible(false))

func _on_jugar_button_up():
	if $Jugar/SubmenuModificadores.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$Jugar/SubmenuModificadores.visible = true

func _on_tabla_clasificacion_button_up() -> void:
	if $TablaClasificacion/SubmenuTablaClasificacion.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$TablaClasificacion/SubmenuTablaClasificacion.visible = true


func _on_como_jugar_button_up() -> void:
	if $ComoJugar/SubmenuComoJugar.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$ComoJugar/SubmenuComoJugar.visible = true


func _on_creditos_button_up() -> void:
	if $Creditos/SubmenuCreditos.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$Creditos/SubmenuCreditos.visible = true


func _on_opciones_button_up() -> void:
	if $Opciones/SubmenuOpciones.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$Opciones/SubmenuOpciones.visible = true
