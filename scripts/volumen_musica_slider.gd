extends HSlider

@export var audio_bus_name : String
var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	value = AudioServer.get_bus_volume_linear(audio_bus_id)

func _on_value_changed(value2: float) -> void:
	AudioServer.set_bus_volume_linear(audio_bus_id, value2)
