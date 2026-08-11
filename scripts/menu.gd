extends Node2D

var skip = 1
var tweens: Array[Tween] = []

@onready var hover: AudioStreamPlayer = $Hover
@onready var click_button: AudioStreamPlayer = $ClickButton

func _input(e):
	if $AnimationPlayer.is_playing() and e is InputEventMouseButton and e.is_pressed() and e.get_button_index() == 1:
		$AnimationPlayer.play("RESET")


func _ready() -> void:
	$SubmenuTablaClasificacion/Leaderboard.show_leaderboard()
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
	$SubmenuOpciones/VBoxContainer/HBoxContainer3/VolumenMasterSlider.value = Configuracion.volumen_general
	$SubmenuOpciones/VBoxContainer/HBoxContainer2/VolumenMusicaSlider.value = Configuracion.volumen_musica
	$SubmenuOpciones/VBoxContainer/HBoxContainer2/VolumenSFXSlider.value = Configuracion.volumen_sfx
	$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckFullscreen.button_pressed = Configuracion.pantalla_completa
	$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers.button_pressed = Configuracion.JQKA_numeros
	if Configuracion.JQKA_numeros:
		$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJQKA.texture = preload("uid://pl06f2wvhjnu")
	else:
		$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJQKA.texture = preload("uid://v0q2xce3l23k")

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
		
		vida_max = $SubmenuModificadores/ScrollContainer/VBoxContainer/VidaMaxima/SliderVidaMax.get_value()
		
		# Se precarga la escena...
		var partida = preload("res://escenas/partida.tscn").instantiate()
		var baraja_nodo = partida.get_node("Baraja")
		# ...para seguidamente adignarlo los valores obtenidos
		baraja_nodo.modificadores_activos = modificadores_activos
		baraja_nodo.flags_cartas = flags_cartas
		baraja_nodo.num_cartas_extra = num_cartas_extra
		partida.vida_max = vida_max
		partida.vida = vida_max
		
		# Se cambia de escena
		get_tree().root.add_child(partida)
		queue_free()
		get_tree().current_scene = partida
	else:
		mostrar_error_numero_cartas()

func mostrar_error_numero_cartas():
	$SubmenuModificadores/JugarModificadores.text = "NECESITAS AL MENOS 4 CARTAS"
	$SubmenuModificadores/JugarModificadores.disabled = true

	await get_tree().create_timer(1.0).timeout

	$SubmenuModificadores/JugarModificadores.text = "PARTIDA CON MODIFICADORES"
	$SubmenuModificadores/JugarModificadores.disabled = false

func esconder_submenus():
	get_tree().get_nodes_in_group("Submenus").map(func(e):e.set_visible(false))

func animacion_squash_submenus(submenu : Node):
	var tween: Tween = create_tween()
	
	tween.tween_property(submenu,
	"scale",
	Vector2(1.15, 0.9),
	0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(submenu,
	"scale",
	Vector2.ONE,
	0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_jugar_button_up():
	if $SubmenuModificadores.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$SubmenuModificadores.visible = true
		animacion_squash_submenus($SubmenuModificadores)


func _on_tabla_clasificacion_button_up() -> void:
	if $SubmenuTablaClasificacion.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$SubmenuTablaClasificacion.visible = true
		animacion_squash_submenus($SubmenuTablaClasificacion)


func _on_como_jugar_button_up() -> void:
	if $SubmenuComoJugar.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$SubmenuComoJugar.visible = true
		animacion_squash_submenus($SubmenuComoJugar)


func _on_creditos_button_up() -> void:
	if $SubmenuCreditos.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$SubmenuCreditos.visible = true
		animacion_squash_submenus($SubmenuCreditos)


func _on_opciones_button_up() -> void:
	if $SubmenuOpciones.visible:
		esconder_submenus()
	else:
		esconder_submenus()
		$SubmenuOpciones.visible = true
		animacion_squash_submenus($SubmenuOpciones)


func _on_check_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Configuracion.pantalla_completa = toggled_on


func _on_check_jqka_numbers_toggled(toggled_on: bool) -> void:
	Configuracion.JQKA_numeros = toggled_on
	if toggled_on:
		$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJQKA.texture = preload("uid://pl06f2wvhjnu")
	else:
		$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckJQKANumbers/SpriteJQKA.texture = preload("uid://v0q2xce3l23k")


func _on_alternar_todas_toggled(toggled_on: bool) -> void:
	for n in find_children("*","TextureButton"):
		n.button_pressed = toggled_on


func particulas_estrellas():
	for index in range(9):
		$Personaje/GPUParticles2D.restart()
		await get_tree().create_timer(0.25 * skip).timeout
		if skip == 0 : return


func _on_animated_button_button_up() -> void:
	get_tree().quit()


func _on_tutorial_button_up() -> void:
	var partida_tuto = preload("res://escenas/partida_tutorial.tscn").instantiate()
	get_tree().root.add_child(partida_tuto)
	queue_free()
	get_tree().current_scene = partida_tuto
