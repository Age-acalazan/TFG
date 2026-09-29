class_name Carta

extends Node2D

enum PALO { PICAS, TREBOLES, CORAZONES, DIAMANTES, TIENDA, HERRERIA, BOMBA }
const HOVER_ARRIBA := 8
const HOVER_TIEMPO := 0.1

var tween_rojo : Tween

signal carta_clicada(carta : Carta)
signal cursor_entra_area_monstruo(carta : Carta)

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var palo_carta : PALO
@export_range(0,14) var valor : int
@export var img : Texture2D

func _ready():
	$Sprite2D.texture = img

# Cuando se clica
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.get_button_index() == 1:
		emit_signal("carta_clicada", self)

#________________________________________________________________
# Enrojece el sprite para dar feedback de que no se puede clicar con el arma
func poner_en_rojo():
	if tween_rojo and tween_rojo.is_running():
		tween_rojo.kill()
	tween_rojo = create_tween()
	
	modulate = Color(1,0,0,1)
	
	tween_rojo.tween_property(
		self,
		"modulate",
		Color.WHITE,
		0.2
	)

#________________________________________________________________

func desactivar():
	$Area2D/CollisionShape2D.disabled = true

func activar():
	$Area2D/CollisionShape2D.disabled = false

func esta_activa() -> bool:
	return !$Area2D/CollisionShape2D.disabled

func _on_area_2d_mouse_entered():
	create_tween().tween_property(sprite_2d,
	"position",
	Vector2(0,-HOVER_ARRIBA),
	HOVER_TIEMPO)
	if palo_carta == PALO.PICAS or palo_carta == PALO.TREBOLES:
		$PrediccionDaño.visible = true
		emit_signal("cursor_entra_area_monstruo", self)


func _on_area_2d_mouse_exited() -> void:
	create_tween().tween_property(sprite_2d,
	"position",
	Vector2(0,0),
	HOVER_TIEMPO)
	$PrediccionDaño.visible = false

func animacion_borrar():
	$AnimationPlayer.play("borrar_carta")
	await $AnimationPlayer.animation_finished
	

func animacion_huir():
	$AnimationPlayer.play("huir")
	await $AnimationPlayer.animation_finished
	$Sprite2D.modulate = Color.WHITE
	$Sprite2D.position.y = 0.0
