extends TextureButton

func _ready():
	button_pressed = false
	modulate = Color.WHITE if button_pressed else Color(0.3,0.3,0.3,1) 

func _on_toggled(button_pressed2: bool):
	modulate = Color.WHITE if button_pressed2 else Color(0.3,0.3,0.3,1) 
