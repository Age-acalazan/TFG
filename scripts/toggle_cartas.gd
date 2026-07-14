extends TextureButton
const STYLE_BOX_BORDE_BLANCO = preload("uid://dqb6i6ejuooq8")
const STYLE_BOX_SIN_BORDE = preload("uid://cggbrq0141nq0")

func _ready():
	button_pressed = false
	modulate = Color.WHITE if button_pressed else Color(0.3,0.3,0.3,1) 

func _on_toggled(button_pressed2: bool):
	modulate = Color.WHITE if button_pressed2 else Color(0.3,0.3,0.3,1) 


func _on_mouse_entered() -> void:
	$Panel.add_theme_stylebox_override("panel",STYLE_BOX_BORDE_BLANCO)


func _on_mouse_exited() -> void:
	$Panel.add_theme_stylebox_override("panel",STYLE_BOX_SIN_BORDE)
