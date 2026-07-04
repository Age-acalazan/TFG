extends Node

var carta_escena = preload("res://escenas/carta.tscn")
var baraja: Array[Carta] = []
var sala : Array[Carta] = []:
	set(valor):
		print(str(valor))
var disable_recargar_sala = false

var modificadores_activos : bool = false
var flags_cartas : Dictionary[String,bool] = {}
var num_cartas_extra : Dictionary[String,int] = {}

signal carta_clicada(carta : Carta)
signal _on_cursor_entra_area_monstruo2(carta : Carta)
signal sala_recargada()
signal empezando_recargar_sala()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#crear_cartas()
	#baraja.shuffle()
	#iniciar_sala()
	#mostrar_baraja()
	#mostrar_sala()


func inicializar_partida():
	crear_cartas()
	baraja.shuffle()
	iniciar_sala()
	mostrar_sala()

# Crea las cartas y las mete a la baraja
func crear_cartas():
	var carta
	for n in range(2,15):
		
		# Monstruo picas
		if !modificadores_activos or flags_cartas.get(str(n)+"p"): # Mira si es una partida con modificadores y en ese caso si la carta está activa
			carta = crear_una_carta( #Carga los sprites con números o letras según la variable
				load("res://assets/sprites/monstruos"+("_numeros/" if Configuracion.JQKA_numeros else "/")+str(n)+"p.png"),
				n, #valor de la carta
				Carta.PALO.PICAS)
			baraja.append(carta) # Añade la carta a la baraja
			carta.connect("carta_clicada", _on_carta_clicada)
			carta.connect("cursor_entra_area_monstruo", _on_cursor_entra_area_monstruo)
		
		
		# Monstruo treboles
		if !modificadores_activos or flags_cartas.get(str(n)+"t"):
			carta = crear_una_carta( #Carga los sprites con números o letras según la variable
				load("res://assets/sprites/monstruos"+("_numeros/" if Configuracion.JQKA_numeros else "/")+str(n)+"t.png"),
				n, #valor de la carta
				Carta.PALO.TREBOLES)
			baraja.append(carta) # Añade la carta a la baraja
			carta.connect("carta_clicada", _on_carta_clicada)
			carta.connect("cursor_entra_area_monstruo", _on_cursor_entra_area_monstruo)
		
		# Los ases y figuras de las cartas rojas no se usan en este juego
		if n >=2 and n <= 10:
			# Vida corazones
			if !modificadores_activos or flags_cartas.get(str(n)+"c"):
				carta = crear_una_carta(
					load("res://assets/sprites/vida/"+str(n)+"c.png"),
					n, #valor de la carta
					Carta.PALO.CORAZONES)
				baraja.append(carta) # Añade la carta a la baraja
				carta.connect("carta_clicada", _on_carta_clicada)
		
			# Armas diamantes
			if !modificadores_activos or flags_cartas.get(str(n)+"d"):
				carta = crear_una_carta(
					load("res://assets/sprites/armas/"+str(n)+"d.png"),
					n, #valor de la carta
					Carta.PALO.DIAMANTES)
				baraja.append(carta) # Añade la carta a la baraja
				carta.connect("carta_clicada", _on_carta_clicada)
	
	
	# Cartas extra
	if modificadores_activos:
		
		# Tienda
		for s in range(0,num_cartas_extra.get("Tienda")):
			carta = crear_una_carta(
				load("res://assets/sprites/extras/tienda.png"),
				0, #valor de la carta
				Carta.PALO.TIENDA)
			baraja.append(carta) # Añade la carta a la baraja
			carta.connect("carta_clicada", _on_carta_clicada)
		
		# Herreria
		for s in range(0,num_cartas_extra.get("Herreria")):
			carta = crear_una_carta(
				load("res://assets/sprites/extras/herreria.png"),
				0, #valor de la carta
				Carta.PALO.HERRERIA)
			baraja.append(carta) # Añade la carta a la baraja
			carta.connect("carta_clicada", _on_carta_clicada)
		
		# Bomba
		for s in range(0,num_cartas_extra.get("Bomba")):
			carta = crear_una_carta(
				load("res://assets/sprites/extras/bomba.png"),
				0, #valor de la carta
				Carta.PALO.BOMBA)
			baraja.append(carta) # Añade la carta a la baraja
			carta.connect("carta_clicada", _on_carta_clicada)


# Función que crea una sola carta asignando propiedades básicas
func crear_una_carta(img:Texture2D, valor: int, palo: Carta.PALO):
	var carta = carta_escena.instantiate()
	carta.img = img
	carta.valor = valor
	carta.palo_carta = palo
	return carta

# Dibuja la baraja y la añade a los nodos
func mostrar_baraja():
	var i =0
	var n = 0
	# Se pueden referenciar las cartas accediendo al nodo tanto por baraja 
	# como por get_children
	#for c in get_children():
	for c in baraja: 
		c.position = Vector2(100+i*200,100+n*200)
		i+=1
		if i == 8:
			i = 0 
			n +=1

# Se añaden 4 cartas inicales a la sala
func iniciar_sala():
	for n in 4:
		sala.append(baraja.pop_front())

# _____________________________________________________________
# Tras 2 segundos, se ejecuta la "segunda" parte de la función
func recargar_sala():
	if sala.size() == 1 and baraja.size() != 0 and $TimerRecargarSala.is_stopped() and !disable_recargar_sala:
		$TimerRecargarSala.start()
		empezando_recargar_sala.emit()
		# Desactiva que el area2d detecte clicks mediante su CollisionShape2D
		sala.get(0).find_child("CollisionShape2D").disabled = true

func tras_recargar_sala() -> void:
	while baraja.size() != 0 and sala.size() < 4:
		sala.append(baraja.pop_front())
	mostrar_sala()
	# Reactiva el CollisionShape2D
	sala.get(0).find_child("CollisionShape2D").disabled = false
	emit_signal("sala_recargada")
# _____________________________________________________________


func mostrar_sala():
	for c in sala:
		#La posicion de la carta en sala es sala.rfind(c)
		c.position = Vector2(sala.rfind(c)*200,0)
		if !c.is_inside_tree():
			add_child(c)
		

#La señal se reenvía al nodo main y se borra la carta de la baraja
func _on_carta_clicada(carta: Carta):
	emit_signal("carta_clicada", carta)

func _on_cursor_entra_area_monstruo(carta: Carta):
	emit_signal("_on_cursor_entra_area_monstruo2", carta)	

func huir():
	#Añade las cartas de la sala al fondo de la baraja
	for carta in sala:
		remove_child(carta)
		baraja.push_back(carta)
	#Vacía la sala
	sala.clear()
	#Recarga
	while sala.size() < 4:
		sala.append(baraja.pop_front())
	mostrar_sala()

func bomba():
	for carta in sala:
		remove_child(carta)
		carta.queue_free()
	#Vacía la sala
	sala.clear()
	$TimerBomba.start()
	empezando_recargar_sala.emit()

func tras_bomba() -> void:
	while sala.size() < 4 and !baraja.is_empty():
		sala.append(baraja.pop_front())
	mostrar_sala()
	emit_signal("sala_recargada")

func desactivar_cartas():
	for c in sala:
		c.visible = false
	disable_recargar_sala = true

func check_no_mas_cartas() -> bool:
	return sala.is_empty() and baraja.is_empty()

func calcular_puntuacion_muerte() -> int:
	for carta in sala:
		remove_child(carta)
		baraja.push_back(carta)
	sala.clear()
	
	var puntos := 0
	for carta in baraja:
		if carta.palo_carta == Carta.PALO.TREBOLES or carta.palo_carta == Carta.PALO.PICAS:
			puntos -= carta.valor
	return puntos
	
	
