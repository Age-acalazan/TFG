extends Button

class_name AnimatedButton

const REST_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.1, 1.1)
const SQUASH_SCALE := Vector2(1.15, 0.9)

const HOVER_TIME := 0.2
const SQUASH_TIME := 0.1
var _tween: Tween = null
var mouse_in: bool = false

func _ready() -> void:
	# Asegura que tenga el offset transform activado y conecta las señales
	offset_transform_enabled = true
	mouse_entered.connect(animacion_mouse_entered)
	mouse_exited.connect(animacion_mouse_exited)
	button_up.connect(animacion_button_up)

func restart_tween() -> Tween:
	if _tween and _tween.is_valid():
		_tween.kill() # Abandona la animacion que se estaba reproducionedo
	_tween = create_tween()
	return _tween

func animacion_mouse_entered() -> void:
	mouse_in = true
	if not self.disabled:
		restart_tween().tween_property(self,
		^"offset_transform_scale",
		HOVER_SCALE,
		HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func animacion_mouse_exited() -> void:
	mouse_in = false
	restart_tween().tween_property(self,
	^"offset_transform_scale",
	REST_SCALE,
	HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func animacion_button_up() -> void:
	var tween: Tween = restart_tween()
	
	tween.tween_property(self,
	^"offset_transform_scale",
	SQUASH_SCALE,
	SQUASH_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self,
	^"offset_transform_scale",
	HOVER_SCALE if mouse_in else REST_SCALE,
	HOVER_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
