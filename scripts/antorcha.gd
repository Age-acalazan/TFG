extends OmniLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween1 = create_tween().set_loops()
	tween1.tween_property(self,"omni_range",2.0,1.0)
	tween1.tween_property(self,"omni_range",1.5,1.0)
	
	var tween2 = create_tween().set_loops()
	tween2.tween_property(self,"light_energy",2.0,1.0)
	tween2.tween_property(self,"light_energy",1.0,1.0)
	
	var tween3 = create_tween().set_loops()
	tween3.tween_property($Sprite3D,"scale",Vector3(0.5,0.5,0.5),1.0)
	tween3.tween_property($Sprite3D,"scale",Vector3(0.3,0.3,0.3),1.0)
