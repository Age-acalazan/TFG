extends Node2D

@onready var como_jugar = $ComoJugar/PopupComoJugar
@onready var creditos = $Creditos/PopupCreditos

func _ready() -> void:
	$Creditos/PopupCreditos.visible = false
	$ComoJugar/PopupComoJugar.visible = false

func _on_jugar_button_up() -> void:
	get_tree().change_scene_to_file("res://escenas/partida.tscn")


func _on_como_jugar_button_up() -> void:
	if creditos.visible:
		creditos.visible = false
		como_jugar.visible = true
	elif como_jugar.visible:
		como_jugar.visible = false
	else:
		como_jugar.visible = true


func _on_creditos_button_up() -> void:
	if como_jugar.visible:
		como_jugar.visible = false
		creditos.visible = true
	elif creditos.visible:
		creditos.visible = false
	else:
		creditos.visible = true
