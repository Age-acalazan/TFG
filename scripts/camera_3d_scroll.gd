extends Camera3D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
		#position.z = fmod(position.z - 1 * delta, 8.0)
	pass


func avanzar_sala():
	var tween1 = create_tween()
	var tween2 = create_tween()
	
	# Este tween se encarga de mover la cámara hacia alante
	tween1.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween1.tween_property(self, "position:z" ,-2,2.0).as_relative()
	#tween1.tween_property(self, "position:z" ,-1,1.0).as_relative()
	
	# Este tween simula el movimiento de caminar de arriba abajo
	tween2.tween_method(
		func(t):
			v_offset = sin(t * TAU * 2.0) * 0.05,
		0.0,
		2.0,
		2.0
	)
	
	await tween1.finished
	position.z = fmod(position.z, 8.0)
