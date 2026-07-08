extends Camera3D


func avanzar_sala():
	var tween1 = create_tween()
	var tween2 = create_tween()
	
	# Este tween se encarga de mover la cámara hacia alante
	tween1.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween1.tween_property(self, "position:z" ,-2,2.0).as_relative()
	
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

func secuencia_victoria():
	var tween1 = create_tween()
	var tween2 = create_tween()
	var duracion := (14+position.z)*2/3
	
	tween1.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween1.tween_property(self, "position:z" ,-14,duracion)
	
	# Este tween simula el tambaleo de caminar de arriba abajo
	tween2.tween_method(
		func(t):
			v_offset = sin(t * TAU * 2.0) * 0.05,
		0.0,
		duracion-1,
		duracion-1
	)
	
	await tween1.finished
