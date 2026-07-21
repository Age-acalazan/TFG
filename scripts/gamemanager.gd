extends Node2D

@export var vida_max : int = 2000
var vida : int = vida_max:
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
		$HUD/LabelVida.set_text(str(vida)+"♥️")
var valor_monstruo_sobre_arma : int
var valor_arma : int = 0:
	set(valor):
		valor_arma = valor
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
			$HUD/CambiarArma.text = "Usando arma"
		else:
			$HUD/CambiarArma.text = "Desarmado"
var numero_total_cartas : int
var oro : int:
	set(valor):
		oro = valor
		$HUD/Oro.set_text(str(oro))

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


func _ready():
	baraja.inicializar_partida()
	$HUD/LabelVida.set_text(str(vida)+"♥️")
	usando_arma = false
	oro = 1000
	label_arma.text="Sin arma"
	label_monstruo_anterior.text="Sin monstruo anterior"
	numero_total_cartas = baraja.baraja.size()+4
	$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/"+str(numero_total_cartas)
	$HUD/Oro.visible = true if baraja.modificadores_activos else false
	$Sonido/BGM.play()
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
		$SubmenuOpciones/VBoxContainer/Continuar,
		$SubmenuOpciones/VBoxContainer/SalirDePartida
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
	$SubmenuOpciones/VBoxContainer/Continuar.button_up.connect(button_pressed.bind(sonido_pausa_out))
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
	if baraja.num_cartas_activas() > 1 or baraja.baraja.is_empty():
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
						borrar_carta(carta)
					else: # Arma equipada y no aplicable
						carta.poner_en_rojo()
						sonido_negar.play()
				else: # Desarmado
					vida -= carta.valor
					oro += carta.valor
					sonido_puño.play()
					borrar_carta(carta)
			
			Carta.PALO.CORAZONES:#####################################################
				if carta.valor == 10:
					sonido_beber.play()
				else:
					sonido_comer.play()
				if vida != vida_max:
					vida += carta.valor
					sonido_sanar.play()
				borrar_carta(carta)
				
			Carta.PALO.DIAMANTES:#####################################################
				usando_arma = true
				valor_arma = carta.valor
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
				$Baraja.visible = false
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
				$Baraja.visible = false
				sonido_herreria_in.play()
				await herreria.tree_exited
				tienda_herreria_salida()
				borrar_carta(carta)
				
			Carta.PALO.BOMBA:#####################################################
				vida -= randi_range(0,10)
				baraja.bomba()
				sonido_bomba.play()
		
		
		# Limita el valor de la vida por arriba y por abajo
		vida = clampi(vida, 0, vida_max)
		
		# Caso de muerte
		if vida == 0:
			muerte()
		
		# Una vez la sala no está completa, huir se desactiva
		$HUD/Huir.disabled = true
		
		# Contar cartas restantes
		$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/"+str(numero_total_cartas)
		
		if baraja.check_no_mas_cartas() and vida > 0:
			victoria()
			$HUD/Opciones.disabled = true


func muerte():
	$Baraja.visible = false
	$HUD.visible = false
	$FinPartida/Letrero.text = "HAS MUERTO"
	$FinPartida.visible = true
	mostrar_puntuacion(baraja.calcular_puntuacion_muerte())
	if !baraja.modificadores_activos:
		$FinPartida/Leaderboard.save_score(baraja.calcular_puntuacion_muerte())
	$FinPartida/Leaderboard.show_leaderboard()
	
	$Sonido/BGM.stop()
	$Sonido/MusicaFinPartida.stream = preload("uid://byob06le748u7")
	$Sonido/MusicaFinPartida.play()

func victoria():
	# Espera a que termine el tween de esa función
	await $HUD/SubViewport/Camera3D.secuencia_victoria()
	
	# lógica del fade a negro
	$FadeNegro.visible = true
	var tween = create_tween()
	tween.tween_property($FadeNegro, "color", Color(0,0,0,1),5)
	# Espera a que termine el tween del fade a negro
	await tween.finished
	
	$Baraja.visible = false
	$HUD.visible = false
	$FinPartida/Letrero.text = "VICTORIA"
	$FinPartida.visible = true
	mostrar_puntuacion(vida)
	if !baraja.modificadores_activos:
		$FinPartida/Leaderboard.save_score(vida)
	$FinPartida/Leaderboard.show_leaderboard()
	
	$Sonido/BGM.stop()
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
	baraja.recargar_sala()

func _on_cambiar_arma_pressed() -> void:
	if valor_arma:
		usando_arma = !usando_arma

func _on_huir_pressed() -> void:
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
	carta.get_node("PrediccionDaño").text = "-"+str(daño)+"♥️"


func _on_opciones_button_up() -> void:
	$HUD.set_visible(false)
	$Baraja.set_visible(false)
	$SubmenuOpciones.set_visible(true)


func _on_continuar_button_up() -> void:
	$HUD.set_visible(true)
	$SubmenuOpciones.set_visible(false)
	if !has_node("HUD/Tienda") and !has_node("HUD/Herreria"):
		$Baraja.set_visible(true)

func compra_realizada(datos : Array):
	oro -= datos[2]
	if datos[1] == "c":
		vida += datos[0]
		vida = clampi(vida, 0, vida_max)
	else:
		usando_arma = true
		valor_arma = datos[0]
		valor_monstruo_sobre_arma = 15
		monstruo_anterior.texture = null
		label_arma.text = "Valor del arma: "+ str(valor_arma)
		label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
	sonido_tienda_compra.play()


func reparacion_hecha(precio : int): 
	usando_arma = true
	valor_monstruo_sobre_arma = 15
	monstruo_anterior.texture = null
	label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
	oro -= precio
	sonido_herreria_reparacion.play()

func tienda_herreria_salida():
	$HUD/CambiarArma.disabled = false
	$HUD/Huir.disabled = false
	$Baraja.set_visible(true)
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
	
