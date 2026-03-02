extends Node2D

@onready var como_jugar = $ComoJugar/PopupComoJugar
@onready var creditos = $Creditos/PopupCreditos
@onready var tabla_clasificaion = $TablaClasificacion/Leaderboard

func _ready() -> void:
	$Creditos/PopupCreditos.visible = false
	$ComoJugar/PopupComoJugar.visible = false
	$TablaClasificacion/Leaderboard.show_leaderboard()

func _on_jugar_button_up() -> void:
	get_tree().change_scene_to_file("res://escenas/partida.tscn")


func _on_como_jugar_button_up() -> void:
	if como_jugar.visible:
		como_jugar.visible = false
	else:
		creditos.visible = false
		tabla_clasificaion.visible = false
		$TablaClasificacion/Panel.visible = false
		como_jugar.visible = true


func _on_creditos_button_up() -> void:
	if creditos.visible:
		creditos.visible = false
	else:
		tabla_clasificaion.visible = false
		$TablaClasificacion/Panel.visible = false
		como_jugar.visible = false
		creditos.visible = true


func _on_tabla_clasificacion_button_up() -> void:
	if tabla_clasificaion.visible:
		tabla_clasificaion.visible = false
		$TablaClasificacion/Panel.visible = false
	else:
		creditos.visible = false
		como_jugar.visible = false
		tabla_clasificaion.visible = true
		$TablaClasificacion/Panel.visible = true
