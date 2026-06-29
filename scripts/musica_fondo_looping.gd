extends AudioStreamPlayer

@export var audioInicio : AudioStream
@export var audioLoop : AudioStream

func _ready() -> void:
	set_stream(audioInicio)
	play()

func _on_finished() -> void:
	set_stream(audioLoop)
	play()
