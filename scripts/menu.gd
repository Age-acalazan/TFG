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
