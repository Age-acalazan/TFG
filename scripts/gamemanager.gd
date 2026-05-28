extends Node2D

var vida : int
const vidamax : int = 20
var valor_monstruo_sobre_arma : int
var valor_arma : int
var usando_arma : bool
@onready var label_vida: Label = $HUD/LabelVida
@onready var label_arma: Label = $HUD/LabelArma
@onready var label_monstruo_anterior: Label = $HUD/LabelMonstruoAnterior
@onready var monstruo_anterior: Sprite2D = $HUD/MonstruoAnterior
@onready var cambiar_arma: Button = $HUD/CambiarArma
@onready var baraja: Node = $Baraja

func _ready():
	baraja.inicializar_partida()
	vida = vidamax
	label_vida.text="HP: "+ str(vida)
	usando_arma = false
	label_arma.text="Sin arma"
	label_monstruo_anterior.text="Sin monstruo anterior"
	cambiar_arma.text = "Desarmado"
	$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/44"

func _on_baraja_carta_clicada(carta: Carta) -> void:
	# Reduce o aumenta la vida
	match carta.palo_carta:
		Carta.PALO.TREBOLES, Carta.PALO.PICAS:
			# Sustituye monstruo anterior
			if usando_arma: # Arma equipada
				if carta.valor < valor_monstruo_sobre_arma: # Arma equipada y aplicable
					monstruo_anterior.texture = carta.img
					valor_monstruo_sobre_arma = carta.valor
					label_monstruo_anterior.text = "Último monstruo sobre arma: "+ str(valor_monstruo_sobre_arma)
					# Se le resta a la vida el daño del monstruo menos lo mitigado con el arma
					vida -= clampi(carta.valor - valor_arma,0, vidamax)
					borrar_carta(carta)
				else: # Arma equipada y no aplicable
					carta.poner_en_rojo()
			else: # Desarmado
				vida -= carta.valor
				borrar_carta(carta)
		
		Carta.PALO.CORAZONES:
			vida += carta.valor
			borrar_carta(carta)
			
		Carta.PALO.DIAMANTES:
			usando_arma = true
			cambiar_arma.text = "Usando arma"
			valor_arma = carta.valor
			valor_monstruo_sobre_arma = 15
			monstruo_anterior.texture = null
			label_arma.text = "Valor del arma: "+ str(valor_arma)
			label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
			borrar_carta(carta)
		
	# Limita el valor de la vida por arriba y por abajo
	vida = clampi(vida, 0, vidamax)
	label_vida.text="HP: "+ str(vida)
	
	# Caso de muerte
	if vida == 0:
		muerte()
	
	baraja.mostrar_sala()
	baraja.recargar_sala()
	
	# Contar cartas restantes
	$HUD/LabelRestantes.text = str(baraja.baraja.size()+baraja.sala.size())+"/44"
	
	if baraja.check_no_mas_cartas() and vida > 0:
		victoria()
	
	

func muerte():
	baraja.desactivar_cartas()
	$HUD.visible = false
	$FinPartida/Letrero.text = "HAS MUERTO"
	$FinPartida.visible = true
	mostrar_puntuacion(baraja.calcular_puntuacion_muerte())
	$FinPartida/Leaderboard.save_score(baraja.calcular_puntuacion_muerte())
	$FinPartida/Leaderboard.show_leaderboard()

func victoria():
	baraja.desactivar_cartas()
	$HUD.visible = false
	$FinPartida/Letrero.text = "VICTORIA"
	$FinPartida.visible = true
	mostrar_puntuacion(vida)
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
	if usando_arma:
		cambiar_arma.text = "Usando arma"
	else:
		cambiar_arma.text = "Desarmado"

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

func _on_cursor_entra_area_monstruo2(carta: Carta) -> void:
	var daño : int = 0
	if usando_arma: # Arma equipada
		daño = 0 - clampi(carta.valor - valor_arma,0, vidamax)
	else: # Desarmado
		daño = 0 - carta.valor
	#carta.get_node("PrediccionDaño").text = str(daño)+"♥️"
	#print(carta.get_node("PrediccionDaño").text)
