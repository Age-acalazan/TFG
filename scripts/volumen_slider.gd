extends HSlider

@export var audio_bus_name : String
@onready var audio_stream_player: AudioStreamPlayer = $"../../HBoxContainer2/VolumenSFXSlider/AudioStreamPlayer"
var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	value = AudioServer.get_bus_volume_linear(audio_bus_id)

func _on_value_changed(nuevo_valor: float) -> void:
	AudioServer.set_bus_volume_linear(audio_bus_id, nuevo_valor)
	match audio_bus_name:
		"Master":
			Configuracion.volumen_general = nuevo_valor
		"Musica":
			Configuracion.volumen_musica = nuevo_valor
		"SFX":
			Configuracion.volumen_sfx = nuevo_valor
			audio_stream_player.play()
			
