extends Node2D

var objetos : Dictionary[int, Array] = {} 
var oro : int = 0

signal compra_realizada(datos : Array)
signal tienda_salida()

func _ready() -> void:
	var listaCartas = ["2c", "3c", "4c", "5c", "6c", "7c", "8c", "9c", "10c",
	 "2d", "3d", "4d", "5d", "6d", "7d", "8d", "9d", "10d"]
	listaCartas.shuffle()
	listaCartas.resize(3)
	for n in range(0,3):
		
		var carta = listaCartas[n]
		var precio = oro_aleatorio_pesado(int(carta.substr(0,carta.length()-1)))
		
		# idObjeto : [valor, tipo(c/d), precio]
		objetos.set(n,[int(carta.substr(0,carta.length()-1)),carta[-1],precio])
		
		if carta[-1] == "c":
			get_node("Panel/HBoxContainer/"+str(n)).set_texture_normal(
				load("res://assets/sprites/vida/"+carta+".png"))
		else:
			get_node("Panel/HBoxContainer/"+str(n)).set_texture_normal(
				load("res://assets/sprites/armas/"+carta+".png"))
			
		get_node("Panel/HBoxContainer/"+str(n)+"/oro").set_text(str(precio)+"🪙")


func oro_aleatorio_pesado(valor : int):
	return ceili(randi_range(100,150)*valor/10.0)

func poner_en_rojo(nodo : Node):
	var tween = create_tween()

	tween.tween_property(
		nodo,
		"modulate",
		Color(1,0,0,1),
		0.0
	)
	
	tween.tween_property(
		nodo,
		"modulate",
		Color.WHITE,
		0.2
	)

func presionado_0() -> void:
	if oro >= objetos.get(0)[2]:
		emit_signal("compra_realizada", objetos.get(0))
		queue_free()
	else:
		poner_en_rojo($"Panel/HBoxContainer/0")


func presionado_1() -> void:
	if oro >= objetos.get(1)[2]:
		emit_signal("compra_realizada", objetos.get(1))
		queue_free()
	else:
		poner_en_rojo($"Panel/HBoxContainer/1")


func presionado_2() -> void:
	if oro >= objetos.get(2)[2]:
		emit_signal("compra_realizada", objetos.get(2))
		queue_free()
	else:
		poner_en_rojo($"Panel/HBoxContainer/2")


func _on_salir_button_up() -> void:
	emit_signal("tienda_salida")
	queue_free()


func _on_salir_mouse_entered() -> void:
	$Hover.play()
