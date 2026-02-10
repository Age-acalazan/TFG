extends Node2D

var vida : int
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
	vida = 20
	label_vida.text="HP: "+ str(vida)
	usando_arma = false
	label_arma.text="Sin arma"
	label_monstruo_anterior.text="Sin monstruo anterior"
	cambiar_arma.text = "Desarmado"

func _on_baraja_carta_clicada(carta: Carta) -> void:
	# Reduce o aumenta la vida
	match carta.palo_carta:
		Carta.PALO.TREBOLES, Carta.PALO.PICAS:
			# Sustituye monstruo anterior
			# TODO: mostrar algún efecto para que si el monstruo sobre arma es menor o igual que el monstruo,
			# haga una acción como de "denegación", tienes primero que cambiar a desarmado
			if usando_arma: # Arma equipada
				if carta.valor < valor_monstruo_sobre_arma: # Arma equipada y aplicable
					monstruo_anterior.texture = carta.img
					valor_monstruo_sobre_arma = carta.valor
					label_monstruo_anterior.text = "Último monstruo sobre arma: "+ str(valor_monstruo_sobre_arma)
					# Se le resta a la vida el daño del monstruo menos lo mitigado con el arma
					vida -= clampi(carta.valor - valor_arma,0, 20)
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
			valor_monstruo_sobre_arma = 14
			monstruo_anterior.texture = null
			label_arma.text = "Valor del arma: "+ str(valor_arma)
			label_monstruo_anterior.text = "Último monstruo sobre arma: Ninguno"
			borrar_carta(carta)
		
	# Limita el valor de la vida por arriba y por abajo
	vida = clampi(vida, 0, 20)
	label_vida.text="HP: "+ str(vida)
	
	baraja.mostrar_sala()
	baraja.recargar_sala()


func _on_cambiar_arma_pressed() -> void:
	if valor_arma:
		usando_arma = !usando_arma
	if usando_arma:
		cambiar_arma.text = "Usando arma"
	else:
		cambiar_arma.text = "Desarmado"

func borrar_carta(carta : Carta):
	baraja.sala.erase(carta)
	carta.queue_free()


func _on_huir_pressed() -> void:
	if baraja.sala.size() == 4:
		baraja.huir()
		#Para que no puedas huir dos veces seguidas
		$HUD/Huir.disabled = true

#Reactiva tras recargarse la sala
func _on_baraja_sala_recargada() -> void:
	$HUD/Huir.disabled = false
