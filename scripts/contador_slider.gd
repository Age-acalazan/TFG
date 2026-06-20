extends HSlider



@warning_ignore("shadowed_variable_base_class")
func _on_value_changed(value: float) -> void:
	$Label2.text = str(int(value))
