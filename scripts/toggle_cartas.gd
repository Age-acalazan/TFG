extends TextureButton

func _ready():
	button_pressed = true

func _on_toggled(button_pressed2: bool):
	modulate = Color.WHITE if button_pressed2 else Color(0.3,0.3,0.3,1) 
