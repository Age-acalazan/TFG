extends TextureButton
const STYLE_BOX_BORDE_BLANCO = preload("uid://dqb6i6ejuooq8")
const STYLE_BOX_SIN_BORDE = preload("uid://cggbrq0141nq0")

func _ready():
	button_pressed = true
	modulate = Color.WHITE if button_pressed else Color(0.3,0.3,0.3,1)

func _on_toggled(button_pressed2: bool):
	modulate = Color.WHITE if button_pressed2 else Color(0.3,0.3,0.3,1) 


func _on_mouse_entered() -> void:
	$Panel.theme_type_variation = "panel_con_borde"


func _on_mouse_exited() -> void:
	$Panel.theme_type_variation = "panel_sin_borde"
