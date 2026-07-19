extends Node2D

@onready var hover: AudioStreamPlayer = $Hover
@onready var click_button: AudioStreamPlayer = $ClickButton

func _ready() -> void:
	$TablaClasificacion/SubmenuTablaClasificacion/Leaderboard.show_leaderboard()
	actualizar_interfaz_ajustes()
	var botones = find_children("*", "Button")
	botones.append_array(find_children("*", "TextureButton"))
	for boton in botones:
		boton.connect("button_up",button_pressed)
		boton.connect("mouse_entered",button_mouse_entered)

# Conectamos por otra parte todos los botones para que hagan sonidos
func button_mouse_entered() -> void:
	hover.play()

func button_pressed() -> void:
	click_button.play()

func  actualizar_interfaz_ajustes() -> void:
	#Ajusta la interfaz del menú de opciones
	$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer3/VolumenMasterSlider.value = Configuracion.volumen_general
	$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer2/VolumenMusicaSlider.value = Configuracion.volumen_musica
	$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer2/VolumenSFXSlider.value = Configuracion.volumen_sfx
	$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckFullscreen.button_pressed = Configuracion.pantalla_completa
	$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers.button_pressed = Configuracion.JQKA_numeros
	if Configuracion.JQKA_numeros:
		$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJKQA.texture = preload("uid://dddqqgpgufuhq")
	else:
		$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJKQA.texture = preload("uid://bsodmfm4l6vab")

func _on_jugar_simple_button_up():
	var partida = preload("res://escenas/partida.tscn").instantiate()
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
	
	if num_cartas_extra.values().reduce(func(accum, n): return accum + n) + \
	 flags_cartas.values().count(true) >= 4 : # El primer elemento del if suma el nº de cartas extra
		
		vida_max = $Jugar/SubmenuModificadores/ScrollContainer/VBoxContainer/VidaMaxima/SliderVidaMax.get_value()
		
		# Se precarga la escena...
		var partida = preload("res://escenas/partida.tscn").instantiate()
		var baraja_nodo = partida.get_node("Baraja")
		# ...para seguidamente adignarlo los valores obtenidos
		baraja_nodo.modificadores_activos = modificadores_activos
		baraja_nodo.flags_cartas = flags_cartas
		baraja_nodo.num_cartas_extra = num_cartas_extra
		partida.vida_max = vida_max
		
		# Se cambia de escena
		get_tree().root.add_child(partida)
		queue_free()
		get_tree().current_scene = partida
	else:
		mostrar_error_numero_cartas()

func mostrar_error_numero_cartas():
	$Jugar/SubmenuModificadores/JugarModificadores.text = "NECESITAS AL MENOS 4 CARTAS"
	$Jugar/SubmenuModificadores/JugarModificadores.disabled = true

	await get_tree().create_timer(1.0).timeout

	$Jugar/SubmenuModificadores/JugarModificadores.text = "PARTIDA CON MODIFICADORES"
	$Jugar/SubmenuModificadores/JugarModificadores.disabled = false

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


func _on_check_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Configuracion.pantalla_completa = toggled_on


func _on_check_jqka_numbers_toggled(toggled_on: bool) -> void:
	Configuracion.JQKA_numeros = toggled_on
	if toggled_on:
		$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJKQA.texture = preload("uid://dddqqgpgufuhq")
	else:
		$Opciones/SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJKQA.texture = preload("uid://bsodmfm4l6vab")


func _on_alternar_todas_toggled(toggled_on: bool) -> void:
	for n in find_children("*","TextureButton"):
		n.button_pressed = toggled_on
