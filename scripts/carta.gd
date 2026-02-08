class_name Carta

extends Node2D

enum PALO { PICAS, TREBOLES, CORAZONES, DIAMANTES, JOKER }
signal carta_clicada(carta : Carta)
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@export var palo_carta : PALO
@export_range(1,13) var valor : int
@export var img : Texture2D

func _ready():
	$Sprite2D.texture = img

func _process(_delta: float) -> void:
	pass
	#if !collision_shape_2d.disabled:
		#sprite_2d.set_modulate(Color(1,1,1,1))
	#else:
		#sprite_2d.set_modulate(Color.RED)


# Cuando se clica
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("carta_clicada", self)

#________________________________________________________________
# Enrojece el sprite para dar feedback de que no se puede clicar con el arma
func poner_en_rojo():
	timer.start()
	sprite_2d.set_modulate(Color(1,0,0,0.8))

func _on_timer_timeout() -> void:
	sprite_2d.set_modulate(Color(1,1,1,1))
#________________________________________________________________
