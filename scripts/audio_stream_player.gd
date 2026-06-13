extends AudioStreamPlayer

const MORE_8_BIT_DRAMA_LOOPING = preload("uid://ctlo7a2wsmh2w")

func _on_finished() -> void:
	set_stream(MORE_8_BIT_DRAMA_LOOPING)
	play()
