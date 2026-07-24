extends Camera3D

@onready var sonido_caminar: AudioStreamPlayer = $Caminar

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
	
	sonidos_caminar(4)
	
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
	
	sonidos_caminar(int(duracion/0.5)-1)
	
	await tween1.finished

func sonidos_caminar(repeticiones : int):
	# Se hace el sonido de dar los pasos
	for _n in range(repeticiones):
		sonido_caminar.play()
		await get_tree().create_timer(0.5).timeout


func camera_shake():
	var elapsed_time:float = 0.0
	while elapsed_time < 0.4:
		h_offset = randf_range(-0.1, 0.1)
		v_offset = randf_range(-0.1, 0.1)
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame
	h_offset = 0.0
	v_offset = 0.0
