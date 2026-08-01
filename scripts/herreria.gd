extends Node2D

var durabilidad_actual : int
var valor_arma : int
var oro : int
var precio : int

signal reparacion_hecha(precio : int)
signal herreria_salida()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if valor_arma != 0:
		$TieneArma.visible = true
		$NoTieneArma.visible = false
		$TieneArma/ImagenArma.texture = load("res://assets/sprites/armas/"+str(valor_arma)+"d.png")
		$TieneArma/LabelActual.text = "Durabilidad\nactual:\n"+str(durabilidad_actual)
		precio = ceili(randi_range(100,150)*valor_arma/10.0)
		$TieneArma/Precio.text = "Precio: "+str(precio)
		if oro < precio:
			$TieneArma/Reparar.disabled = true
			$TieneArma/Precio.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))
		if durabilidad_actual == 15:
			$TieneArma/Reparar.disabled = true
			$TieneArma/LabelActual.text = "Durabilidad\nactual:\nMáxima"
			$TieneArma/LabelActual.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0, 1.0))
	else:
		$NoTieneArma.visible = true

func _on_salir_button_up() -> void:
	emit_signal("herreria_salida")
	queue_free()


func _on_reparar_button_up() -> void:
	emit_signal("reparacion_hecha", precio)
	queue_free()

func _on_reparar_mouse_entered() -> void:
	if not $TieneArma/Reparar.disabled:
		$Hover.play()


func _on_salir_mouse_entered() -> void:
	$Hover.play()
