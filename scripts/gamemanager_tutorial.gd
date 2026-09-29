extends Node2D

@export var vida_max : int 
var vida : int :
	set(valor):
		if vida < valor:
			$HUD/LabelVida.modulate = Color.GREEN
		elif vida > valor:
			$HUD/LabelVida.modulate = Color.RED
		create_tween().tween_property(
			$HUD/LabelVida,
			"modulate",
			Color.WHITE,
			0.4
		)
		vida = valor
		$HUD/LabelVida.set_text(str(vida))
var valor_monstruo_sobre_arma : int
var valor_arma : int = 0:
	set(valor):
		valor_arma = valor
		# Efecto de sonido del arma
		sonido_arma.volume_db = 0.0
		match valor_arma:
			2:
				sonido_arma.stream = load("res://assets/sonidos/efectos/explosion_quick.wav")
				sonido_arma.volume_db = -5.0
			3, 6:
				sonido_arma.stream = load("res://assets/sonidos/efectos/27_sword_miss_2.wav")
				sonido_arma.volume_db = 2.0
			4:
				sonido_arma.stream = load("res://assets/sonidos/efectos/lydmakeren__fx_bowarrow.wav")
			5:
				sonido_arma.stream = load("res://assets/sonidos/efectos/14_human_death_spin_mod.wav")
			7:
				sonido_arma.stream = load("res://assets/sonidos/efectos/07_human_atk_sword_2.wav")
				sonido_arma.volume_db = 2.0
			8, 9:
				sonido_arma.stream = load("res://assets/sonidos/efectos/21_orc_damage_2.wav")
			10:
				sonido_arma.stream = load("res://assets/sonidos/efectos/17_orc_atk_sword_2.wav")
var usando_arma : bool:
	set(valor):
		usando_arma = valor
		if valor:
			$HUD/CambiarArma.icon = load("res://assets/sprites/armas/%dd.png" % valor_arma)
		else:
			$HUD/CambiarArma.icon = imagen_puño
var numero_total_cartas : int
var oro : int:
	set(valor):
		oro = valor
		$HUD/Oro.set_text(str(oro))
var paso : int = 1:
	set(valor):
		paso = valor
		paso_actualizado()
var monstruo_7_clicado : bool = false
var monstruo_8_clicado : bool = false

var particulas_curacion_escena = preload("res://escenas/particulas_curacion.tscn")
var animaciones_arma_escena = preload("res://escenas/animaciones_armas.tscn")
var imagen_puño = preload("res://assets/sprites/ui_y_efectos/puño.png")


@onready var label_arma: Label = $HUD/LabelArma
@onready var label_monstruo_anterior: Label = $HUD/LabelMonstruoAnterior
@onready var monstruo_anterior: Sprite2D = $HUD/MonstruoAnterior
@onready var baraja: Node = $Baraja
@onready var camera_3d: Camera3D = $HUD/SubViewport/Camera3D

@onready var sonido_hover: AudioStreamPlayer = $Sonido/Hover
@onready var sonido_click_button: AudioStreamPlayer = $Sonido/ClickButton
@onready var sonido_negar: AudioStreamPlayer = $Sonido/Negar
@onready var sonido_arma: AudioStreamPlayer = $Sonido/Arma
@onready var sonido_puño: AudioStreamPlayer = $Sonido/Puño
@onready var sonido_pausa_in: AudioStreamPlayer = $Sonido/PausaIn
@onready var sonido_pausa_out: AudioStreamPlayer = $Sonido/PausaOut
@onready var sonido_equipar: AudioStreamPlayer = $Sonido/Equipar
@onready var sonido_desequipar: AudioStreamPlayer = $Sonido/Desequipar
@onready var sonido_huir: AudioStreamPlayer = $Sonido/Huir
@onready var sonido_comer: AudioStreamPlayer = $Sonido/Comer
@onready var sonido_beber: AudioStreamPlayer = $Sonido/Beber
@onready var sonido_sanar: AudioStreamPlayer = $Sonido/Sanar
@onready var sonido_herreria_in: AudioStreamPlayer = $Sonido/HerreriaIn
@onready var sonido_herreria_reparacion: AudioStreamPlayer = $Sonido/HerreriaReparacion
@onready var sonido_tienda_in: AudioStreamPlayer = $Sonido/TiendaIn
@onready var sonido_tienda_compra: AudioStreamPlayer = $Sonido/TiendaCompra
@onready var sonido_tienda_herreria_out: AudioStreamPlayer = $Sonido/TiendaHerreriaOut
@onready var sonido_bomba: AudioStreamPlayer = $Sonido/Bomba
@onready var sonido_puerta: AudioStreamPlayer = $Sonido/Puerta

signal recarga_paso_7

func _ready():
	baraja.inicializar_partida()
	vida = vida_max
	usando_arma = false
	oro = 0
	label_arma.text="Sin arma"
	label_monstruo_anterior.text="Sin monstruo anterior"
	numero_total_cartas = baraja.baraja.size()+4
	$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/"+str(numero_total_cartas)
	$HUD/Oro.visible = true if baraja.modificadores_activos else false
	actualizar_interfaz_ajustes()
	conectar_botones_con_sonido()

func conectar_botones_con_sonido():
	# Lista de nodos tipo boton cuyos sonidos de hover o click son los básicos
	var botones_hover_normal = [
		$HUD/CambiarArma,
		$HUD/Huir,
		$HUD/Opciones,
		$FinPartida/Menu,
		$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckFullscreen,
		$SubmenuOpciones/VBoxContainer/HBoxContainer4/Continuar,
		$SubmenuOpciones/VBoxContainer/HBoxContainer4/SalirDePartida
	]
	for boton in botones_hover_normal:
		boton.mouse_entered.connect(button_mouse_entered.bind(sonido_hover,boton))
	
	var botones_click_normal = [
		$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckFullscreen
	]
	for boton in botones_click_normal:
		boton.button_up.connect(button_pressed.bind(sonido_click_button))
	
	# Lista de nodos tipo boton cuyos sonidos de hover o click son especiales
	$HUD/Opciones.button_up.connect(button_pressed.bind(sonido_pausa_in))
	$SubmenuOpciones/VBoxContainer/HBoxContainer4/Continuar.button_up.connect(button_pressed.bind(sonido_pausa_out))
	$HUD/CambiarArma.button_up.connect(button_pressed_cambiar_arma)
	$HUD/Huir.button_up.connect(button_pressed.bind(sonido_huir))


func button_mouse_entered(player: AudioStreamPlayer, boton: Node):
	if not boton.disabled:
		player.play()

func button_pressed(player: AudioStreamPlayer):
	player.play()

func button_pressed_cambiar_arma():
	if usando_arma:
		sonido_equipar.play()
	else:
		sonido_desequipar.play()

func actualizar_interfaz_ajustes() -> void:
	$SubmenuOpciones/VBoxContainer/HBoxContainer/CheckFullscreen.button_pressed = Configuracion.pantalla_completa
	$SubmenuOpciones/VBoxContainer/HBoxContainer3/VolumenMasterSlider.value = Configuracion.volumen_general
	$SubmenuOpciones/VBoxContainer/HBoxContainer2/VolumenMusicaSlider.value = Configuracion.volumen_musica
	$SubmenuOpciones/VBoxContainer/HBoxContainer2/VolumenSFXSlider.value = Configuracion.volumen_sfx

func _on_baraja_carta_clicada(carta: Carta) -> void:
	#if not (baraja.num_cartas_activas() > 1 or baraja.baraja.is_empty()): return
	# Reduce o aumenta la vida
	match carta.palo_carta:
		Carta.PALO.TREBOLES, Carta.PALO.PICAS:#####################################################
			# Sustituye monstruo anterior
			if usando_arma: # Arma equipada
				if carta.valor < valor_monstruo_sobre_arma: # Arma equipada y aplicable
					monstruo_anterior.texture = carta.img
					valor_monstruo_sobre_arma = carta.valor
					label_monstruo_anterior.text = "Último monstruo sobre arma: "+ str(valor_monstruo_sobre_arma)
					# Se le resta a la vida el daño del monstruo menos lo mitigado con el arma
					vida -= clampi(carta.valor - valor_arma,0, vida_max)
					oro += carta.valor
					sonido_arma.play()
					ejecutar_animacion_arma(valor_arma, carta.global_position)
					borrar_carta(carta)
				else: # Arma equipada y no aplicable
					carta.poner_en_rojo()
					sonido_negar.play()
			else: # Desarmado
				vida -= carta.valor
				oro += carta.valor
				sonido_puño.play()
				ejecutar_animacion_arma(0, carta.global_position)
				borrar_carta(carta)
		
		Carta.PALO.CORAZONES:#####################################################
			if carta.valor == 10:
				sonido_beber.play()
			else:
				sonido_comer.play()
			if vida != vida_max:
				vida += carta.valor
				spawnear_particulas_curacion(carta.global_position)
				sonido_sanar.play()
			borrar_carta(carta)
			
		Carta.PALO.DIAMANTES:#####################################################
			valor_arma = carta.valor
			usando_arma = true
			valor_monstruo_sobre_arma = 15
			monstruo_anterior.texture = null
			label_arma.text = "Valor del arma: "+ str(valor_arma)
			label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
			sonido_equipar.play()
			if $HUD/CambiarArma.disabled:
				$HUD/CambiarArma.disabled = false
			borrar_carta(carta)
		
		Carta.PALO.TIENDA:#####################################################
			var tienda = preload("res://escenas/tienda.tscn").instantiate()
			tienda.oro = oro
			tienda.connect("compra_realizada", compra_realizada)
			tienda.position = Vector2(380,180)
			$HUD.add_child(tienda, true)
			$HUD/CambiarArma.disabled = true
			$HUD/Huir.disabled = true
			baraja.visible = false
			sonido_tienda_in.play()
			await tienda.tree_exited
			tienda_herreria_salida()
			borrar_carta(carta)
		
		Carta.PALO.HERRERIA:#####################################################
			var herreria = preload("res://escenas/herreria.tscn").instantiate()
			herreria.valor_arma = valor_arma
			herreria.oro = oro
			herreria.durabilidad_actual = valor_monstruo_sobre_arma
			herreria.connect("reparacion_hecha", reparacion_hecha)
			herreria.position = Vector2(380,180)
			$HUD.add_child(herreria, true)
			$HUD/CambiarArma.disabled = true
			$HUD/Huir.disabled = true
			baraja.visible = false
			sonido_herreria_in.play()
			await herreria.tree_exited
			tienda_herreria_salida()
			borrar_carta(carta)
			
		Carta.PALO.BOMBA:#####################################################
			vida -= randi_range(0,10)
			sonido_bomba.play()
			baraja.desactivar_cartas()
			$HUD/ExplosionAnimacion.play()
			$HUD/ExplosionParticulas.restart()
			camera_3d.camera_shake()
			await get_tree().create_timer(0.4).timeout
			baraja.bomba()
	
	
	# Limita el valor de la vida por arriba y por abajo
	vida = clampi(vida, 0, vida_max)
	
	# Caso de muerte
	if vida == 0:
		muerte()
	
	# Una vez la sala no está completa, huir se desactiva
	if baraja.sala.size() < 4:
		$HUD/Huir.disabled = true
	
	
	
	# Contar cartas restantes
	$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/"+str(numero_total_cartas)
	
	if baraja.check_no_mas_cartas() and vida > 0:
		victoria()
		$HUD/Opciones.disabled = true
	
	# Lógica del tutorial
	match paso:
		6,9,10:
			paso = paso +1
		4:
			if baraja.sala.size() == 2:
				paso = 5
		11:
			baraja.sala[0].desactivar()
			await baraja.sala_recargada
			paso = 12
		13:
			if carta.valor == 8:
				monstruo_8_clicado = true
			else:
				monstruo_7_clicado = true
			if monstruo_7_clicado and monstruo_8_clicado:
				paso = 14
		14:
			if baraja.sala.size() == 2:
				paso = 15
		15:
			baraja.sala[0].desactivar()
			await baraja.sala_recargada
			paso = 16



func muerte():
	baraja.visible = false
	$HUD.visible = false
	$FinPartida/Letrero.text = "HAS MUERTO"
	$FinPartida.visible = true
	mostrar_puntuacion(baraja.calcular_puntuacion_muerte())
	
	$Sonido/BGM.stop()
	$Sonido/MusicaFinPartida.stream = preload("uid://byob06le748u7")
	$Sonido/MusicaFinPartida.play()

func victoria():
	$FinPartida/Letrero.add_theme_color_override("font_color", Color.WHITE)
	$FinPartida/Puntos.add_theme_color_override("font_color", Color.WHITE)
	# Espera a que termine el tween de esa función
	await camera_3d.secuencia_victoria()
	# lógica de el giro de las puertas
	var puertaD = $Pasillo3/PuertaD
	var puertaI = $Pasillo3/PuertaI
	create_tween().tween_property(puertaD, "rotation:y", -PI/2,3).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(puertaI, "rotation:y", -PI/2,3).set_trans(Tween.TRANS_CUBIC)
	sonido_puerta.play()
	await get_tree().create_timer(2.5).timeout
	camera_3d.secuencia_victoria2()
	# lógica del fade a negro
	$FadeNegro.visible = true
	var tween = create_tween()
	tween.tween_property($FadeNegro, "color", Color(0,0,0,1),5).set_delay(1)
	# Espera a que termine el tween del fade a negro
	await tween.finished
	
	baraja.visible = false
	$HUD.visible = false
	$Sonido/BGM.stop()
	# Se reproduce la cinemática del final
	if !baraja.modificadores_activos:
		var cinematica_final = preload("res://escenas/cinematica_final.tscn").instantiate()
		add_child(cinematica_final)
		await cinematica_final.get_node("AnimationPlayer").animation_finished
		cinematica_final.queue_free()
	$FinPartida/Letrero.text = "VICTORIA"
	$FinPartida.visible = true
	mostrar_puntuacion(vida)
	if !baraja.modificadores_activos:
		$FinPartida/Panel/Leaderboard.save_score(vida)
	$FinPartida/Panel/Leaderboard.show_leaderboard()
	
	$Sonido/MusicaFinPartida.stream = preload("uid://cdqt0oe741oie")
	$Sonido/MusicaFinPartida.play()

# Función que usa un tween para cambiar poco a poco la puntuación displayeada
func mostrar_puntuacion(puntos : int):
	var label := $FinPartida/Puntos
	# Cancelar tween previo si existe
	if label.has_meta("puntos_tween"):
		var old_tween: Tween = label.get_meta("puntos_tween")
		if old_tween:
			old_tween.kill()
	
	var tween := create_tween()
	label.set_meta("puntos_tween", tween)
	
	var actual := 0
	label.text = "0 puntos"
	
	
	tween.tween_method(
		func(value):
			label.text = str(int(value)) + " puntos",
		actual,
		puntos,
		1.5 #Tiempo desde el inicio hasta el final del tween
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	

func borrar_carta(carta : Carta):
	carta.desactivar()
	baraja.sala.erase(carta)
	await carta.animacion_borrar()
	carta.queue_free()
	baraja.mostrar_sala()
	if paso == 7:
		await recarga_paso_7
	baraja.recargar_sala()

func _on_cambiar_arma_pressed() -> void:
	if valor_arma:
		usando_arma = !usando_arma

func _on_huir_pressed() -> void:
	if paso == 8:
		paso = 9
	baraja.huir()
	#Para que no puedas huir dos veces seguidas
	$HUD/Huir.disabled = true

#Reactiva tras recargarse la sala
func _on_baraja_sala_recargada() -> void:
	if baraja.sala.size() == 4:
		$HUD/Huir.disabled = false
	else:
		$HUD/Huir.disabled = true

func _on_menu_button_up() -> void:
	get_tree().change_scene_to_file("res://escenas/menu.tscn")

func _on_salir_de_partida_button_up() -> void:
	get_tree().change_scene_to_file("res://escenas/menu.tscn")

func _on_cursor_entra_area_monstruo2(carta: Carta) -> void:
	var daño : int = 0
	if usando_arma: # Arma equipada
		daño = clampi(carta.valor - valor_arma,0, vida_max)
	else: # Desarmado
		daño = carta.valor
	carta.get_node("PrediccionDaño").text = "-"+str(daño)


func _on_opciones_button_up() -> void:
	$HUD.set_visible(false)
	baraja.set_visible(false)
	$SubmenuOpciones.set_visible(true)


func _on_continuar_button_up() -> void:
	$HUD.set_visible(true)
	$SubmenuOpciones.set_visible(false)
	if !has_node("HUD/Tienda") and !has_node("HUD/Herreria"):
		baraja.set_visible(true)

func compra_realizada(datos : Array):
	$HUD/ParticulasDolar.restart()
	oro -= datos[2]
	if datos[1] == "c":
		vida += datos[0]
		vida = clampi(vida, 0, vida_max)
	else:
		valor_arma = datos[0]
		usando_arma = true
		valor_monstruo_sobre_arma = 15
		monstruo_anterior.texture = null
		label_arma.text = "Valor del arma: "+ str(valor_arma)
		label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
	sonido_tienda_compra.play()


func reparacion_hecha(precio : int): 
	$HUD/ParticulasDolar.restart()
	usando_arma = true
	valor_monstruo_sobre_arma = 15
	monstruo_anterior.texture = null
	label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
	oro -= precio
	sonido_herreria_reparacion.play()

func tienda_herreria_salida():
	$HUD/CambiarArma.disabled = false
	$HUD/Huir.disabled = false
	baraja.set_visible(true)
	# Para que no se mezclen sonido, este se ejecuta si sales sin interactuar con la tienda o herreria
	if not (sonido_tienda_compra.playing or sonido_herreria_reparacion.playing):
		sonido_tienda_herreria_out.play()


func _on_check_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Configuracion.pantalla_completa = toggled_on


func _on_baraja_empezando_recargar_sala() -> void:
	camera_3d.avanzar_sala()
	
func spawnear_particulas_curacion(coordenadas : Vector2):
	var particulas_curacion = particulas_curacion_escena.instantiate()
	particulas_curacion.position = coordenadas
	add_child(particulas_curacion)
	particulas_curacion.restart()
	await get_tree().create_timer(2.0).timeout
	particulas_curacion.queue_free()

func ejecutar_animacion_arma(valor_arma_pasado:int, coordenadas:Vector2):
	var animacion = animaciones_arma_escena.instantiate()
	animacion.position = coordenadas
	add_child(animacion)
	animacion.play(str(valor_arma_pasado))
	await animacion.animation_finished
	animacion.queue_free()


func _on_button_button_up() -> void:
	vida_max = 500
	vida = 500
	oro = 2000


func paso_actualizado():
	match paso:
		1:
			pass
		2:
			$HUD/Popup/FlechaIndicadora.visible = true
			$HUD/Popup/FlechaIndicadora.position = Vector2(784.0,-320.0)
			$HUD/Popup/FlechaIndicadora.rotation = 0.0
			$HUD/Popup/TextoPopup.text = "Este es el contador de cartas. Indica las cartas restantes que quedan en la mazmorra. Para salir victorioso, tendrás que eliminar todas las cartas del mazo. Haz click aquí para continuar."
		3:
			$Baraja.visible = true
			baraja.sala[0].desactivar()
			baraja.sala[1].desactivar()
			baraja.sala[2].desactivar()
			baraja.sala[3].desactivar()
			$HUD/Popup/FlechaIndicadora.visible = false
			$HUD/Popup/TextoPopup.text = "Esto es una sala, cada sala tiene hasta 4 cartas. Pueden ser monstruos de [color=121212]tréboles[/color] o [color=121212]picas[/color], comidas de [color=ed1c24]corazones[/color], o armas de [color=ed1c24]diamantes[/color]. Haz click aquí para continuar."
		4:
			baraja.sala[2].activar()
			baraja.sala[3].activar()
			$HUD/Popup/TextoPopup.text = "Puedes luchar contra monstruos clicando sobre ellos. ¡Prueba a derrotar a los dos de la derecha!"
		5:
			$HUD/Popup/FlechaIndicadora.visible = true
			$HUD/Popup/FlechaIndicadora.position = Vector2(16.0,-312.0)
			$HUD/Popup/FlechaIndicadora.rotation = -PI/2
			$HUD/Popup/TextoPopup.text = "Uff, parece que eso ha dolido… Cada uno de los monstruos te ha quitado [color=ffbd37]tanta vida como indica en su carta[/color]. Haz click aquí para continuar."
		6:
			$HUD/Popup/FlechaIndicadora.visible = false
			baraja.sala[0].activar()
			$HUD/Popup/TextoPopup.text = "Vamos a sanar esas heridas. Interactúa con la ensalada para comértela."
		7:
			$HUD/Popup/TextoPopup.text = "Cuando sólo queda una carta en la sala, se rellenan las cartas y pasamos a [color=ffbd37]la siguiente sala[/color]. Haz click aquí para continuar."
		8:
			$HUD/Popup/TextoPopup.text = ""
			await baraja.sala_recargada
			$HUD/Popup/FlechaIndicadora.visible = true
			$HUD/Popup/FlechaIndicadora.position = Vector2(40.0,-208.0)
			$HUD/Popup/FlechaIndicadora.rotation = -PI/2
			$BloqueadorHuir.visible = false
			baraja.sala[0].desactivar()
			baraja.sala[1].desactivar()
			baraja.sala[2].desactivar()
			baraja.sala[3].desactivar()
			$HUD/Popup/TextoPopup.text = "Vaya… Los monstruos de esta sala son muy fuertes, mejor huimos para que estas cartas se coloquen al final del mazo. Puedes huir mientras la sala esté llena pero no puedes dos veces seguidas."
		9:
			await baraja.huir_finalizado
			$HUD/Popup/FlechaIndicadora.visible = false
			$BloqueadorHuir.visible = true
			baraja.sala[0].desactivar()
			baraja.sala[1].desactivar()
			baraja.sala[3].desactivar()
			$HUD/Popup/TextoPopup.text = "Ahí tienes un arma. ¡Cógela!"
		10:
			baraja.sala[2].activar()
			$HUD/Popup/TextoPopup.text = "Ahora ese monstruo no te hará 8 de daño, sino 4. [color=ffbd37]Al daño del monstruo se le resta el de tu arma[/color], pudiendo mitigar el daño por completo con un buen arma. Atácalo y luego cúrate."
		11:
			baraja.sala[0].activar()
			baraja.sala[1].activar()
		12:
			baraja.sala[0].desactivar()
			baraja.sala[1].desactivar()
			baraja.sala[2].desactivar()
			baraja.sala[3].desactivar()
			$HUD/Popup/FlechaIndicadora.visible = true
			$HUD/Popup/FlechaIndicadora.position = Vector2(-80.0,-56.0)
			$HUD/Popup/FlechaIndicadora.rotation = deg_to_rad(-135.0)
			$HUD/Popup/TextoPopup.text = "Este es el último monstruo con el que has usado tu arma actual y representa su durabilidad. Haz click aquí para continuar."
		13:
			baraja.sala[1].activar()
			baraja.sala[2].activar()
			$HUD/Popup/FlechaIndicadora.visible = false
			$HUD/Popup/TextoPopup.text = "Podrás seguir usando el arco contra monstruos menores a la durabilidad de tu arma, pero [color=ffbd37]no contra monstruos mayores o iguales[/color]. Lucha contra los monstruos."
		14:
			$HUD/Popup/FlechaIndicadora.visible = true
			$HUD/Popup/FlechaIndicadora.position = Vector2(40.0,-96.0)
			$HUD/Popup/FlechaIndicadora.rotation = -PI/2
			$BloqueadorCambiarArma.visible = false
			$HUD/Popup/TextoPopup.text = "Para derrotar al 8 de tréboles tendrás que [color=ffbd37]luchar a puños[/color]. Desequipa tu arco."
		15:
			baraja.sala[0].activar()
			baraja.sala[1].activar()
			$HUD/Popup/FlechaIndicadora.visible = false
			$HUD/Popup/TextoPopup.text = "Pasa a la siguiente sala."
		16:
			baraja.sala[0].activar()
			baraja.sala[1].activar()
			baraja.sala[2].activar()
			baraja.sala[3].activar()
			$HUD/Popup/TextoPopup.text = "Pues parece que hasta aquí has llegado. [color=ffbd37]¡Suerte en la próxima![/color]"


func _on_texto_popup_gui_input(event: InputEvent) -> void:
	# Es un evento del ratón en el que se presiona(no se suelta) y además es con el click izquierdo
	if event is InputEventMouseButton and event.is_pressed() and event.get_button_index() == 1:
		match paso:
			1,2,3,5,12:
				paso = paso + 1
			7:
				paso = paso + 1
				emit_signal("recarga_paso_7")
