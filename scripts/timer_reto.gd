extends Timer

@onready var label = $"../TiempoRestante"

func _process(_delta: float) -> void:
	label.text = str(time_left).pad_decimals(0)
