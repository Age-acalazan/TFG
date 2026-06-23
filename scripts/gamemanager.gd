extends Node2D

var vida : int:
	set(valor):
		vida = valor
		$HUD/LabelVida.set_text(str(vida)+"♥️")
var vida_max : int = 20
var valor_monstruo_sobre_arma : int
var valor_arma : int = 0
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
		$HUD/Oro.set_text(str(oro)+"🪙")

@onready var label_arma: Label = $HUD/LabelArma
@onready var label_monstruo_anterior: Label = $HUD/LabelMonstruoAnterior
@onready var monstruo_anterior: Sprite2D = $HUD/MonstruoAnterior
@onready var baraja: Node = $Baraja

func _ready():
	baraja.inicializar_partida()
	vida = vida_max
	usando_arma = false
	oro = 100
	$HUD/LabelVida.text=str(vida)+"♥️"
	label_arma.text="Sin arma"
	label_monstruo_anterior.text="Sin monstruo anterior"
	numero_total_cartas = baraja.baraja.size()+4
	$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/"+str(numero_total_cartas)
	$HUD/Oro.visible = true if baraja.modificadores_activos else false

func _on_baraja_carta_clicada(carta: Carta) -> void:
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
					borrar_carta(carta)
				else: # Arma equipada y no aplicable
					carta.poner_en_rojo()
			else: # Desarmado
				vida -= carta.valor
				oro += carta.valor
				borrar_carta(carta)
		
		Carta.PALO.CORAZONES:#####################################################
			vida += carta.valor
			borrar_carta(carta)
			
		Carta.PALO.DIAMANTES:#####################################################
			usando_arma = true
			valor_arma = carta.valor
			valor_monstruo_sobre_arma = 15
			monstruo_anterior.texture = null
			label_arma.text = "Valor del arma: "+ str(valor_arma)
			label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
			borrar_carta(carta)
		
		Carta.PALO.TIENDA:#####################################################
			var tienda = preload("res://escenas/tienda.tscn").instantiate()
			tienda.oro = oro
			tienda.connect("compra_realizada", compra_realizada)
			tienda.connect("tienda_salida", tienda_herreria_salida)
			tienda.position = Vector2(380,180)
			$HUD.add_child(tienda, true)
			$HUD/CambiarArma.disabled = true
			$HUD/Huir.disabled = true
			$Baraja.visible = false
			borrar_carta(carta)
		
		Carta.PALO.HERRERIA:#####################################################
			var herreria = preload("res://escenas/herreria.tscn").instantiate()
			herreria.valor_arma = valor_arma
			herreria.oro = oro
			herreria.durabilidad_actual = valor_monstruo_sobre_arma
			herreria.connect("herreria_salida", tienda_herreria_salida)
			herreria.connect("reparacion_hecha", reparacion_hecha)
			herreria.position = Vector2(380,180)
			$HUD.add_child(herreria, true)
			$HUD/CambiarArma.disabled = true
			$HUD/Huir.disabled = true
			$Baraja.visible = false
			borrar_carta(carta)
			
		Carta.PALO.BOMBA:#####################################################
			vida -= randi_range(0,1)
			baraja.bomba()
	
	
	# Limita el valor de la vida por arriba y por abajo
	vida = clampi(vida, 0, vida_max)
	
	# Caso de muerte
	if vida == 0:
		muerte()
	
	baraja.mostrar_sala()
	baraja.recargar_sala()
	
	# Contar cartas restantes
	$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/"+str(numero_total_cartas)
	
	if baraja.check_no_mas_cartas() and vida > 0:
		victoria()


func muerte():
	baraja.desactivar_cartas()
	$HUD.visible = false
	$FinPartida/Letrero.text = "HAS MUERTO"
	$FinPartida.visible = true
	mostrar_puntuacion(baraja.calcular_puntuacion_muerte())
	if !baraja.modificadores_activos:
		$FinPartida/Leaderboard.save_score(baraja.calcular_puntuacion_muerte())
	$FinPartida/Leaderboard.show_leaderboard()

func victoria():
	baraja.desactivar_cartas()
	$HUD.visible = false
	$FinPartida/Letrero.text = "VICTORIA"
	$FinPartida.visible = true
	mostrar_puntuacion(vida)
	if !baraja.modificadores_activos:
		$FinPartida/Leaderboard.save_score(vida)
	$FinPartida/Leaderboard.show_leaderboard()

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
	baraja.sala.erase(carta)
	carta.queue_free()

func _on_cambiar_arma_pressed() -> void:
	if valor_arma:
		usando_arma = !usando_arma

func _on_huir_pressed() -> void:
	if baraja.sala.size() == 4:
		baraja.huir()
		#Para que no puedas huir dos veces seguidas
		$HUD/Huir.disabled = true

#Reactiva tras recargarse la sala
func _on_baraja_sala_recargada() -> void:
	$HUD/Huir.disabled = false

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
	tienda_herreria_salida()

func reparacion_hecha(precio : int): 
	usando_arma = true
	valor_monstruo_sobre_arma = 15
	monstruo_anterior.texture = null
	label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
	oro -= precio
	tienda_herreria_salida()

func tienda_herreria_salida():
	$HUD/CambiarArma.disabled = false
	$HUD/Huir.disabled = false
	$Baraja.set_visible(true)
